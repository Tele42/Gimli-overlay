# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Generate shell script containing firmware update bundle.
#

inherit cros-workon

# @ECLASS-VARIABLE: CROS_FIRMWARE_BCS_OVERLAY
# @DESCRIPTION: (Optional) Name of board overlay on Binary Component Server
: ${CROS_FIRMWARE_BCS_OVERLAY:=${BOARD_OVERLAY##*/}}

# @ECLASS-VARIABLE: CROS_FIRMWARE_MAIN_IMAGE
# @DESCRIPTION: (Optional) Location of system firmware (BIOS) image
: ${CROS_FIRMWARE_MAIN_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_MAIN_RW_IMAGE
# @DESCRIPTION: (Optional) Location of RW system firmware image
: ${CROS_FIRMWARE_MAIN_RW_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BUILD_MAIN_RW_IMAGE
# @DESCRIPTION: (Optional) Re-sign and generate a RW system firmware image.
: ${CROS_FIRMWARE_BUILD_MAIN_RW_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_IMAGE
# @DESCRIPTION: (Optional) Location of EC firmware image
: ${CROS_FIRMWARE_EC_IMAGE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EC_VERSION
# @DESCRIPTION: (Optional) Version name of EC firmware
: ${CROS_FIRMWARE_EC_VERSION:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_PLATFORM
# @DESCRIPTION: (Optional) Platform name of firmware
: ${CROS_FIRMWARE_PLATFORM:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_SCRIPT
# @DESCRIPTION: (Optional) Entry script file name of updater
: ${CROS_FIRMWARE_SCRIPT:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_UNSTABLE
# @DESCRIPTION: (Optional) Mark firmware as unstable (always RO+RW update)
: ${CROS_FIRMWARE_UNSTABLE:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_BINARY
# @DESCRIPTION: (Optional) location of custom flashrom tool
: ${CROS_FIRMWARE_FLASHROM_BINARY:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_EXTRA_LIST
# @DESCRIPTION: (Optional) Semi-colon separated list of additional resources
: ${CROS_FIRMWARE_EXTRA_LIST:=}

# @ECLASS-VARIABLE: CROS_FIRMWARE_FORCE_UPDATE
# @DESCRIPTION: (Optional) Always add "force update firmware" tag.
: ${CROS_FIRMWARE_FORCE_UPDATE:=}

# Check for EAPI 2+
case "${EAPI:-0}" in
	4|3|2) ;;
	*) die "unsupported EAPI" ;;
esac

# $board-overlay/make.conf may contain these flags to always create "firmware
# from source".
IUSE="bootimage cros_ec depthcharge"

# Some tools (flashrom, iotools, mosys, ...) were bundled in the updater so we
# don't write RDEPEND=$DEPEND. RDEPEND should have an explicit list of what it
# needs to extract and execute the updater.
DEPEND="
	>=chromeos-base/vboot_reference-1.0-r230
	chromeos-base/vpd
	dev-util/shflags
	>=sys-apps/flashrom-0.9.4-r269
	sys-apps/mosys
	"

# Build firmware from source.
DEPEND="$DEPEND
	bootimage? ( sys-boot/chromeos-bootimage )
	cros_ec? ( chromeos-base/chromeos-ec )
	"

# Maintenance note:  The factory install shim downloads and executes
# the firmware updater.  Consequently, runtime dependencies for the
# updater are also runtime dependencies for the install shim.
#
# The contents of RDEPEND below must also be present in the
# chromeos-base/chromeos-factoryinstall ebuild in PROVIDED_DEPEND.
# If you make any change to the list below, you may need to make a
# matching change in the factory install ebuild.
#
# TODO(hungte) remove gzip/tar if we have busybox
RDEPEND="
	app-arch/gzip
	app-arch/sharutils
	app-arch/tar
	chromeos-base/vboot_reference
	sys-apps/util-linux"

RESTRICT="mirror"

# Local variables.

UPDATE_SCRIPT="chromeos-firmwareupdate"
FW_IMAGE_LOCATION=""
FW_RW_IMAGE_LOCATION=""
EC_IMAGE_LOCATION=""
EXTRA_LOCATIONS=()

# New SRC_URI based approach.

_add_source() {
	local var="$1"
	local input="${!var}"
	local protocol="${input%%://*}"
	local uri="${input#*://}"
	local overlay="${CROS_FIRMWARE_BCS_OVERLAY#overlay-}"
	local user="bcs-${overlay#variant-*-}"
	local bcs_url="gs://chromeos-binaries/HOME/${user}/overlay-${overlay}"

	# Input without ${protocol} are local files (ex, ${FILESDIR}/file).
	case "${protocol}" in
		bcs)
			SRC_URI+=" ${bcs_url}/${CATEGORY}/${PN}/${uri}"
			;;
		http|https)
			SRC_URI+=" ${input}"
			;;
	esac
}

_unpack_archive() {
	local var="$1"
	local input="${!var}"
	local archive="${input##*/}"
	local folder="${S}/.dist/${archive}"

	# Remote source files (bcs://, http://, ...) are downloaded into
	# ${DISTDIR}, which is the default location for command 'unpack'.
	# For any other files (ex, ${FILESDIR}/file), use complete file path.
	local unpack_name="${input}"
	if [[ "${unpack_name}" =~ "://" ]]; then
		input="${DISTDIR}/${archive}"
		unpack_name="${archive}"
	fi

	case "${input##*.}" in
		tar|tbz2|tbz|bz|gz|tgz|zip|xz) ;;
		*)
			eval ${var}="'${input}'"
			return
			;;
	esac

	mkdir -p "${folder}" || die "Not able to create ${folder}"
	(cd "${folder}" && unpack "${unpack_name}") ||
		die "Failed to unpack ${unpack_name}."
	local contents=($(ls "${folder}"))
	if [[ ${#contents[@]} -gt 1 ]]; then
		# Currently we can only serve one file (or directory).
		ewarn "WARNING: package ${input} contains multiple files."
	fi
	eval ${var}="'${folder}/${contents}'"
}

cros-firmware_src_unpack() {
	cros-workon_src_unpack
	local i

	for i in {FW,FW_RW,EC}_IMAGE_LOCATION; do
		_unpack_archive ${i}
	done

	for ((i = 0; i < ${#EXTRA_LOCATIONS[@]}; i++)); do
		_unpack_archive "EXTRA_LOCATIONS[$i]"
	done
}

_add_param() {
	local prefix="$1"
	local value="$2"

	if [[ -n "$value" ]]; then
		echo "$prefix '$value' "
	fi
}

_add_bool_param() {
	local prefix="$1"
	local value="$2"

	if [[ -n "$value" ]]; then
		echo "$prefix "
	fi
}

cros-firmware_src_compile() {
	local image_cmd="" ext_cmd="" local_image_cmd=""
	local root="${ROOT%/}"

	# Prepare images
	image_cmd+="$(_add_param -b "${FW_IMAGE_LOCATION}")"
	image_cmd+="$(_add_param -e "${EC_IMAGE_LOCATION}")"
	image_cmd+="$(_add_param -w "${FW_RW_IMAGE_LOCATION}")"
	image_cmd+="$(_add_param --ec_version "${CROS_FIRMWARE_EC_VERSION}")"
	image_cmd+="$(_add_bool_param --create_bios_rw_image \
		      "${CROS_FIRMWARE_BUILD_MAIN_RW_IMAGE}")"

	# Prepare extra commands
	ext_cmd+="$(_add_bool_param --unstable "${CROS_FIRMWARE_UNSTABLE}")"
	ext_cmd+="$(_add_param --extra "$(IFS=:; echo "${EXTRA_LOCATIONS[*]}")")"
	ext_cmd+="$(_add_param --script "${CROS_FIRMWARE_SCRIPT}")"
	ext_cmd+="$(_add_param --platform "${CROS_FIRMWARE_PLATFORM}")"
	ext_cmd+="$(_add_param --flashrom "${CROS_FIRMWARE_FLASHROM_BINARY}")"
	ext_cmd+="$(_add_param --tool_base \
	            "$root/firmware/utils:$root/usr/sbin:$root/usr/bin")"

	# Pack firmware update script!
	if [ -z "$image_cmd" ]; then
		# Create an empty update script for the generic case
		# (no need to update)
		einfo "Building empty firmware update script"
		echo -n > ${UPDATE_SCRIPT}
	else
		# create a new script
		einfo "Build ${BOARD_USE} firmware updater: $image_cmd $ext_cmd"
		./pack_firmware.sh $image_cmd $ext_cmd -o $UPDATE_SCRIPT ||
		die "Cannot pack firmware."
	fi

	# Create local updaters
	local local_image_cmd="" output_bom output_file
	if use cros_ec; then
		local_image_cmd+="-e $root/firmware/ec.bin "
	fi
	if use bootimage; then
		if use depthcharge; then
			einfo "Updater for local fw"
			output_file="updater.sh"
			./pack_firmware.sh -b $root/firmware/image.bin \
				-o $output_file $local_image_cmd $ext_cmd ||
				die "Cannot pack local firmware."
			if [[ -z "$image_cmd" ]]; then
				# When no pre-built binaries are available,
				# dupe local updater to system updater.
				cp -f "$output_file" "$UPDATE_SCRIPT"
			fi
		else
			for fw_file in $root/firmware/image-*.bin; do
				einfo "Updater for local fw - $fw_file"
				output_bom=${fw_file##*/image-}
				output_bom=${output_bom%%.bin}
				output_file=updater-$output_bom.sh
				./pack_firmware.sh -b $fw_file -o $output_file \
					$local_image_cmd $ext_cmd ||
					die "Cannot pack local firmware."
			done
		fi
	elif use cros_ec; then
		# TODO(hungte) Deal with a platform that has only EC and no
		# BIOS, which is usually incorrect configuration.
		die "Sorry, platform without local BIOS EC is not supported."
	fi
}

cros-firmware_src_install() {
	# install the main updater program
	dosbin $UPDATE_SCRIPT || die "Failed to install update script."

	# install factory wipe script
	dosbin firmware-factory-wipe

	# install updaters for firmware-from-source archive.
	if use bootimage; then
		exeinto /firmware
		doexe updater*.sh
	fi

	# The "force_update_firmware" tag file is used by chromeos-installer.
	if [ -n "$CROS_FIRMWARE_FORCE_UPDATE" ]; then
		insinto /root
		touch .force_update_firmware
		doins .force_update_firmware
	fi
}

# @FUNCTION: _expand_list
# @USAGE <var> <ifs> <string>
# @DESCRIPTION:
# Internal function to expand a string (separated by ifs) into bash array.
_expand_list() {
	local var="$1" ifs="$2"
	IFS="${ifs}" read -r -a ${var} <<<"${*:3}"
}

# @FUNCTION: cros-firmware_setup_source
# @DESCRIPTION:
# Configures all firmware binary source files to SRC_URI, and updates local
# destination mapping (*_LOCATION). Must be invoked after CROS_FIRMWARE_*_IMAGE
# are set.
cros-firmware_setup_source() {
	local i

	FW_IMAGE_LOCATION="${CROS_FIRMWARE_MAIN_IMAGE}"
	FW_RW_IMAGE_LOCATION="${CROS_FIRMWARE_MAIN_RW_IMAGE}"
	EC_IMAGE_LOCATION="${CROS_FIRMWARE_EC_IMAGE}"
	_expand_list EXTRA_LOCATIONS ";" "${CROS_FIRMWARE_EXTRA_LIST}"

	for i in {FW,FW_RW,EC}_IMAGE_LOCATION; do
		_add_source ${i}
	done

	for ((i = 0; i < ${#EXTRA_LOCATIONS[@]}; i++)); do
		_add_source "EXTRA_LOCATIONS[$i]"
	done
}

# If "inherit cros-firmware" appears at end of ebuild file, build source URI
# automatically. Otherwise, you have to put an explicit call to
# "cros-firmware_setup_source" at end of ebuild file.
[[ -n "${CROS_FIRMWARE_MAIN_IMAGE}" ]] && cros-firmware_setup_source

EXPORT_FUNCTIONS src_unpack src_compile src_install
