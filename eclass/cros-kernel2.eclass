# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

[[ ${EAPI} != "4" ]] && die "Only EAPI=4 is supported"

inherit binutils-funcs cros-board toolchain-funcs linux-info

HOMEPAGE="http://www.chromium.org/"
LICENSE="GPL-2"
SLOT="0"

DEPEND="sys-apps/debianutils
	initramfs? ( chromeos-base/chromeos-initramfs )
	netboot_ramfs? ( chromeos-base/chromeos-initramfs )
"

IUSE="-device_tree -kernel_sources -wireless34 -wifi_testbed_ap"
STRIP_MASK="/usr/lib/debug/boot/vmlinux"

# Build out-of-tree and incremental by default, but allow an ebuild inheriting
# this eclass to explicitly build in-tree.
: ${CROS_WORKON_OUTOFTREE_BUILD:=1}
: ${CROS_WORKON_INCREMENTAL_BUILD:=1}

# Config fragments selected by USE flags
# ...fragments will have the following variables substitutions
# applied later (needs to be done later since these values
# aren't reliable when used in a global context like this):
#   %ROOT% => ${ROOT}

CONFIG_FRAGMENTS=(
	blkdevram
	ca0132
	cifs
	dyndebug
	fbconsole
	gdmwimax
	gobi
	highmem
	i2cdev
	initramfs
	kgdb
	kvm
	mbim
	netboot_ramfs
	nfs
	pcserial
	qmi
	realtekpstor
	samsung_serial
	systemtap
	tpm
	vfat
	wifi_testbed_ap
	wireless34
	x32
)

blkdevram_desc="ram block device"
blkdevram_config="
CONFIG_BLK_DEV_RAM=y
CONFIG_BLK_DEV_RAM_COUNT=16
CONFIG_BLK_DEV_RAM_SIZE=16384
"

ca0132_desc="CA0132 ALSA codec"
ca0132_config="
CONFIG_SND_HDA_CODEC_CA0132=y
CONFIG_SND_HDA_DSP_LOADER=y
"

cifs_desc="Samba/CIFS Support"
cifs_config="
CONFIG_CIFS=m
"

dyndebug_desc="Enable Dynamic Debug"
dyndebug_config="
CONFIG_DYNAMIC_DEBUG=y
"

fbconsole_desc="framebuffer console"
fbconsole_config="
CONFIG_FRAMEBUFFER_CONSOLE=y
"

gdmwimax_desc="GCT GDM72xx WiMAX support"
gdmwimax_config="
CONFIG_WIMAX_GDM72XX=m
CONFIG_WIMAX_GDM72XX_USB=y
CONFIG_WIMAX_GDM72XX_USB_PM=y
"

gobi_desc="Qualcomm Gobi modem driver"
gobi_config="
CONFIG_USB_NET_GOBI=m
"

highmem_desc="highmem"
highmem_config="
CONFIG_HIGHMEM64G=y
"

i2cdev_desc="I2C device interface"
i2cdev_config="
CONFIG_I2C_CHARDEV=y
"

kgdb_desc="Enable kgdb"
kgdb_config="
CONFIG_KGDB=y
CONFIG_KGDB_KDB=y
"""

tpm_desc="TPM support"
tpm_config="
CONFIG_TCG_TPM=y
CONFIG_TCG_TIS=y
"

initramfs_desc="Initramfs for factory install shim and recovery image"
initramfs_config='
CONFIG_INITRAMFS_SOURCE="%ROOT%/var/lib/misc/initramfs.cpio.xz"
CONFIG_INITRAMFS_COMPRESSION_XZ=y
'

netboot_ramfs_desc="Network boot install initramfs"
netboot_ramfs_config='
CONFIG_INITRAMFS_SOURCE="%ROOT%/var/lib/misc/netboot_ramfs.cpio.xz"
CONFIG_INITRAMFS_COMPRESSION_XZ=y
'

vfat_desc="vfat"
vfat_config="
CONFIG_NLS_CODEPAGE_437=y
CONFIG_NLS_ISO8859_1=y
CONFIG_FAT_FS=y
CONFIG_VFAT_FS=y
"

kvm_desc="KVM"
kvm_config="
CONFIG_HAVE_KVM=y
CONFIG_HAVE_KVM_IRQCHIP=y
CONFIG_HAVE_KVM_EVENTFD=y
CONFIG_KVM_APIC_ARCHITECTURE=y
CONFIG_KVM_MMIO=y
CONFIG_KVM_ASYNC_PF=y
CONFIG_KVM=m
CONFIG_KVM_INTEL=m
# CONFIG_KVM_AMD is not set
# CONFIG_KVM_MMU_AUDIT is not set
CONFIG_VIRTIO=m
CONFIG_VIRTIO_BLK=m
CONFIG_VIRTIO_NET=m
CONFIG_VIRTIO_CONSOLE=m
CONFIG_VIRTIO_RING=m
CONFIG_VIRTIO_PCI=m
"

# TODO(benchan): Remove the 'mbim' use flag and unconditionally enable the
# CDC MBIM driver once Chromium OS fully supports MBIM.
mbim_desc="CDC MBIM driver"
mbim_config="
CONFIG_USB_NET_CDC_MBIM=m
"

nfs_desc="NFS"
nfs_config="
CONFIG_USB_NET_AX8817X=y
CONFIG_DNOTIFY=y
CONFIG_DNS_RESOLVER=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NETWORK_FILESYSTEMS=y
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
CONFIG_NFSD_V4=y
CONFIG_NFS_COMMON=y
CONFIG_NFS_FS=y
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFS_V3=y
CONFIG_NFS_V4=y
CONFIG_ROOT_NFS=y
CONFIG_RPCSEC_GSS_KRB5=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y
CONFIG_USB_USBNET=y
CONFIG_IP_PNP=y
CONFIG_IP_PNP_DHCP=y
"

pcserial_desc="PC serial"
pcserial_config="
CONFIG_SERIAL_8250=y
CONFIG_SERIAL_8250_CONSOLE=y
CONFIG_SERIAL_8250_PCI=y
CONFIG_PARPORT=y
CONFIG_PARPORT_PC=y
CONFIG_PARPORT_SERIAL=y
"

qmi_desc="QMI WWAN driver"
qmi_config="
CONFIG_USB_NET_QMI_WWAN=m
"

samsung_serial_desc="Samsung serialport"
samsung_serial_config="
CONFIG_SERIAL_SAMSUNG=y
CONFIG_SERIAL_SAMSUNG_CONSOLE=y
"

realtekpstor_desc="Realtek PCI card reader"
realtekpstor_config="
CONFIG_RTS_PSTOR=m
"

systemtap_desc="systemtap support"
systemtap_config="
CONFIG_KPROBES=y
CONFIG_DEBUG_INFO=y
"

wifi_testbed_ap_desc="Defer ath9k EEPROM regulatory"
wifi_testbed_ap_warning="
Don't use the wifi_testbed_ap flag unless you know what you are doing!
An image built with this flag set must never be run outside a
sealed RF chamber!
"
wifi_testbed_ap_config="
CONFIG_ATH_DEFER_EEPROM_REGULATORY=y
"

x32_desc="x32 ABI support"
x32_config="
CONFIG_X86_X32=y
"

wireless34_desc="Wireless 3.4 stack"
wireless34_config="
CONFIG_ATH9K_BTCOEX=m
CONFIG_ATH9K_BTCOEX_COMMON=m
CONFIG_ATH9K_BTCOEX_HW=m
"

# Add all config fragments as off by default
IUSE="${IUSE} ${CONFIG_FRAGMENTS[@]}"
REQUIRED_USE="
	initramfs? ( !netboot_ramfs )
	netboot_ramfs? ( !initramfs )
	initramfs? ( i2cdev tpm )
	netboot_ramfs? ( i2cdev tpm )
"

# If an overlay has eclass overrides, but doesn't actually override this
# eclass, we'll have ECLASSDIR pointing to the active overlay's
# eclass/ dir, but this eclass is still in the main chromiumos tree.  So
# add a check to locate the cros-kernel/ regardless of what's going on.
ECLASSDIR_LOCAL=${BASH_SOURCE[0]%/*}
defconfig_dir() {
        local d="${ECLASSDIR}/cros-kernel"
        if [[ ! -d ${d} ]] ; then
                d="${ECLASSDIR_LOCAL}/cros-kernel"
        fi
        echo "${d}"
}

# @FUNCTION: kernelrelease
# @DESCRIPTION:
# Returns the current compiled kernel version.
# Note: Only valid after src_configure has finished running.
kernelrelease() {
	kmake -s --no-print-directory kernelrelease
}

# @FUNCTION: install_kernel_sources
# @DESCRIPTION:
# Installs the kernel sources into ${D}/usr/src/${P} and fixes symlinks.
# The package must have already installed a directory under ${D}/lib/modules.
install_kernel_sources() {
	local version=$(kernelrelease)
	local dest_modules_dir=lib/modules/${version}
	local dest_source_dir=usr/src/${P}
	local dest_build_dir=${dest_source_dir}/build

	# Fix symlinks in lib/modules
	ln -sfvT "../../../${dest_build_dir}" \
	   "${D}/${dest_modules_dir}/build" || die
	ln -sfvT "../../../${dest_source_dir}" \
	   "${D}/${dest_modules_dir}/source" || die

	einfo "Installing kernel source tree"
	dodir "${dest_source_dir}"
	local f
	for f in "${S}"/*; do
		[[ "$f" == "${S}/build" ]] && continue
		cp -pPR "${f}" "${D}/${dest_source_dir}" ||
			die "Failed to copy kernel source tree"
	done

	dosym "${P}" "/usr/src/linux"

	einfo "Installing kernel build tree"
	dodir "${dest_build_dir}"
	cp -pPR "$(cros-workon_get_build_dir)"/{.config,.version,Makefile,Module.symvers,include} \
		"${D}/${dest_build_dir}" || die

	# Modify Makefile to use the ROOT environment variable if defined.
	# This path needs to be absolute so that the build directory will
	# still work if copied elsewhere.
	sed -i -e "s@${S}@\$(ROOT)/${dest_source_dir}@" \
		"${D}/${dest_build_dir}/Makefile" || die
}

get_build_cfg() {
	echo "$(cros-workon_get_build_dir)/.config"
}

get_build_arch() {
	if [ "${ARCH}" = "arm" ] ; then
		case "${CHROMEOS_KERNEL_SPLITCONFIG}" in
			*tegra*)
				echo "tegra"
				;;
			*exynos*)
				echo "exynos5"
				;;
			*)
				echo "arm"
				;;
		esac
	else
		echo $(tc-arch-kernel)
	fi
}

# @FUNCTION: cros_chkconfig_present
# @USAGE: <option to check config for>
# @DESCRIPTION:
# Returns success of the provided option is present in the build config.
cros_chkconfig_present() {
	local config=$1
	grep -q "^CONFIG_$1=[ym]$" "$(get_build_cfg)"
}

cros-kernel2_pkg_setup() {
	# This is needed for running src_test().  The kernel code will need to
	# be rebuilt with `make check`.  If incremental build were enabled,
	# `make check` would have nothing left to build.
	use test && export CROS_WORKON_INCREMENTAL_BUILD=0
	cros-workon_pkg_setup
	linux-info_pkg_setup
}

# @FUNCTION: emit_its_script
# @USAGE: <output file> <boot_dir> <dtb_dir> <device trees>
# @DESCRIPTION:
# Emits the its script used to build the u-boot fitImage kernel binary
# that contains the kernel as well as device trees used when booting
# it.

emit_its_script() {
	local iter=1
	local its_out=${1}
	shift
	local boot_dir=${1}
	shift
	local dtb_dir=${1}
	shift
	cat > "${its_out}" <<-EOF || die
	/dts-v1/;

	/ {
		description = "Chrome OS kernel image with one or more FDT blobs";
		#address-cells = <1>;

		images {
			kernel@1 {
				data = /incbin/("${boot_dir}/zImage");
				type = "kernel_noload";
				arch = "arm";
				os = "linux";
				compression = "none";
				load = <0>;
				entry = <0>;
			};
	EOF

	local dtb
	for dtb in "$@" ; do
		cat >> "${its_out}" <<-EOF || die
			fdt@${iter} {
				description = "$(basename ${dtb})";
				data = /incbin/("${dtb_dir}/${dtb}");
				type = "flat_dt";
				arch = "arm";
				compression = "none";
				hash@1 {
					algo = "sha1";
				};
			};
		EOF
		((++iter))
	done

	cat <<-EOF >>"${its_script}"
		};
		configurations {
			default = "conf@1";
	EOF

	local i
	for i in $(seq 1 $((iter-1))) ; do
		cat >> "${its_out}" <<-EOF || die
			conf@${i} {
				kernel = "kernel@1";
				fdt = "fdt@${i}";
			};
		EOF
	done

	echo "	};" >> "${its_out}"
	echo "};" >> "${its_out}"
}

kmake() {
	# Allow override of kernel arch.
	local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}

	local cross=${CHOST}-

	if use wireless34 ; then
		set -- "$@" WIFIVERSION="-3.4"
	fi

	# TODO(raymes): Force GNU ld over gold. There are still some
	# gold issues to iron out. See: 13209.
	tc-export LD CC CXX

	local binutils_path=$(get_binutils_path_ld)

	# Hack for using 64-bit kernel with 32-bit user-space
	if [[ "${ARCH}" == "x86" && "${kernel_arch}" == "x86_64" ]]; then
		cross=x86_64-cros-linux-gnu-
		binutils_path=$(echo "$binutils_path" | sed -e \
				's/i686-pc-linux-gnu/x86_64-cros-linux-gnu/g')
		LD=$(echo "$LD" | sed -e \
				's/i686-pc-linux-gnu/x86_64-cros-linux-gnu/g')
		CC=$(echo "$CC" | sed -e \
				's/i686-pc-linux-gnu/x86_64-cros-linux-gnu/g')
		CXX=$(echo "$CXX" | sed -e \
				's/i686-pc-linux-gnu/x86_64-cros-linux-gnu/g')
	fi

	set -- \
		LD="${binutils_path}/ld $(usex x32 '-m elf_x86_64' '')" \
		CC="${CC} -B${binutils_path}" \
		CXX="${CXX} -B${binutils_path}" \
		"$@"

	cw_emake \
		ARCH=${kernel_arch} \
		LDFLAGS="$(raw-ldflags)" \
		CROSS_COMPILE="${cross}" \
		O="$(cros-workon_get_build_dir)" \
		"$@"
}

cros-kernel2_src_prepare() {
	cros-workon_src_prepare
}

cros-kernel2_src_configure() {
	# Use a single or split kernel config as specified in the board or variant
	# make.conf overlay. Default to the arch specific split config if an
	# overlay or variant does not set either CHROMEOS_KERNEL_CONFIG or
	# CHROMEOS_KERNEL_SPLITCONFIG. CHROMEOS_KERNEL_CONFIG is set relative
	# to the root of the kernel source tree.
	local config
	local cfgarch="$(get_build_arch)"

	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		case ${CHROMEOS_KERNEL_CONFIG} in
			/*)
				config="${CHROMEOS_KERNEL_CONFIG}"
				;;
			*)
				config="${S}/${CHROMEOS_KERNEL_CONFIG}"
				;;
		esac
	else
		config=${CHROMEOS_KERNEL_SPLITCONFIG:-"chromiumos-${cfgarch}"}
	fi

	elog "Using kernel config: ${config}"

	# Keep a handle on the old .config in case it hasn't changed.  This way
	# we can keep the old timestamp which will avoid regenerating stuff that
	# hasn't actually changed.
	local temp_config="${T}/old-kernel-config"
	if [[ -e $(get_build_cfg) ]] ; then
		cp -a "$(get_build_cfg)" "${temp_config}"
	else
		rm -f "${temp_config}"
	fi

	if [ -n "${CHROMEOS_KERNEL_CONFIG}" ]; then
		cp -f "${config}" "$(get_build_cfg)" || die
	else
		if [ -e chromeos/scripts/prepareconfig ] ; then
			chromeos/scripts/prepareconfig ${config} \
				"$(get_build_cfg)" || die
		else
			config="$(defconfig_dir)/${cfgarch}_defconfig"
			ewarn "Can't prepareconfig, falling back to default " \
				"${config}"
			cp "${config}" "$(get_build_cfg)" || die
		fi
	fi

	local fragment
	for fragment in ${CONFIG_FRAGMENTS[@]}; do
		use ${fragment} || continue

		local msg="${fragment}_desc"
		local config="${fragment}_config"
		elog "   - adding ${!msg} config"
		local warning="${fragment}_warning"
		local warning_msg="${!warning}"
		if [[ -n "${warning_msg}" ]] ; then
			ewarn "${warning_msg}"
		fi

		echo "${!config}" | \
			sed -e "s|%ROOT%|${ROOT}|g" \
			>> "$(get_build_cfg)" || die
	done

	# Use default for any options not explitly set in splitconfig
	yes "" | kmake oldconfig

	# Restore the old config if it is unchanged.
	if cmp -s "$(get_build_cfg)" "${temp_config}" ; then
		touch -r "${temp_config}" "$(get_build_cfg)"
	fi
}

# @FUNCTION: get_dtb_name
# @USAGE: <dtb_dir>
# @DESCRIPTION:
# Get the name(s) of the device tree binary file(s) to include.

get_dtb_name() {
	local dtb_dir=${1}
	local board_with_variant=$(get_current_board_with_variant)

	# Do a simple mapping for device trees whose names don't match
	# the board_with_variant format; default to just the
	# board_with_variant format.
	case "${board_with_variant}" in
		(tegra2_dev-board)
			echo tegra-harmony.dtb
			;;
		(tegra2_seaboard)
			echo tegra-seaboard.dtb
			;;
		tegra*)
			echo ${board_with_variant}.dtb
			;;
		*)
			local f
			for f in ${dtb_dir}/*.dtb ; do
			    basename ${f}
			done
			;;
	esac
}

cros-kernel2_src_compile() {
	local build_targets=()  # use make default target
	if use arm; then
		build_targets=(
			$(usex device_tree 'zImage dtbs' uImage)
			$(cros_chkconfig_present MODULES && echo "modules")
		)
	fi

	local src_dir="$(cros-workon_get_build_dir)/source"
	local kernel_arch=${CHROMEOS_KERNEL_ARCH:-$(tc-arch-kernel)}
	SMATCH_ERROR_FILE="${src_dir}/chromeos/check/smatch_errors.log"

	if use test && [[ -e "${SMATCH_ERROR_FILE}" ]]; then
		local make_check_cmd="smatch -p=kernel"
		local test_options=(
			CHECK="${make_check_cmd}"
			C=1
		)
		SMATCH_LOG_FILE="$(cros-workon_get_build_dir)/make.log"

		# The path names in the log file are build-dependent.  Strip out
		# the part of the path before "kernel/files" and retains what
		# comes after it: the file, line number, and error message.
		kmake -k ${build_targets[@]} "${test_options[@]}" |& \
			tee "${SMATCH_LOG_FILE}"
	else
		kmake -k ${build_targets[@]}
	fi
}

cros-kernel2_src_test() {
	[[ -e ${SMATCH_ERROR_FILE} ]] || \
		die "smatch whitelist file ${SMATCH_ERROR_FILE} not found!"
	[[ -e ${SMATCH_LOG_FILE} ]] || \
		die "Log file from src_compile() ${SMATCH_LOG_FILE} not found!"

	local prefix="$(realpath "${S}")/"
	grep -w error: "${SMATCH_LOG_FILE}" | grep -o "${prefix}.*" \
		| sed s:"${prefix}"::g > "${SMATCH_LOG_FILE}.errors"
	local num_errors=$(wc -l < "${SMATCH_LOG_FILE}.errors")
	local num_warnings=$(egrep -wc "warn:|warning:" "${SMATCH_LOG_FILE}")
	einfo "smatch found ${num_errors} errors and ${num_warnings} warnings."

	# Create a version of the error database that doesn't have line numbers,
	# since line numbers will shift as code is added or removed.
	local build_dir="$(cros-workon_get_build_dir)"
	local no_line_numbers_file="${build_dir}/no_line_numbers.log"
	sed -r -e "s/(:[0-9]+){1,2}//" \
	       -e "s/\(see line [0-9]+\)//" \
	       "${SMATCH_ERROR_FILE}" > "${no_line_numbers_file}"

	# For every smatch error that came up during the build, check if it is
	# in the error database file.
	local num_unknown_errors=0
	local line=""
	while read line; do
		local no_line_num=$(echo "${line}" | \
			sed -r -e "s/(:[0-9]+){1,2}//" \
			       -e "s/\(see line [0-9]+\)//")
		if ! fgrep -q "${no_line_num}" "${no_line_numbers_file}"; then
			eerror "Non-whitelisted error found: \"${line}\""
			: $(( ++num_unknown_errors ))
		fi
	done < "${SMATCH_LOG_FILE}.errors"

	[[ ${num_unknown_errors} -eq 0 ]] || \
		die "smatch found ${num_unknown_errors} unknown errors."
}

cros-kernel2_src_install() {
	local build_targets=(
		install
		firmware_install
		$(cros_chkconfig_present MODULES && echo "modules_install")
	)

	dodir /boot
	kmake INSTALL_PATH="${D}/boot" INSTALL_MOD_PATH="${D}" \
		"${build_targets[@]}"

	local version=$(kernelrelease)
	if use arm; then
		local boot_dir="$(cros-workon_get_build_dir)/arch/${ARCH}/boot"
		local kernel_bin="${D}/boot/vmlinuz-${version}"
		local zimage_bin="${D}/boot/zImage-${version}"
		local dtb_dir="${boot_dir}"

		# Newer kernels (after linux-next 12/3/12) put dtbs in the dts
		# dir.  Use that if we we find no dtbs directly in boot_dir.
		# Note that we try boot_dir first since the newer kernel will
		# actually rm ${boot_dir}/*.dtb so we'll have no stale files.
		if ! ls "${dtb_dir}"/*.dtb &> /dev/null; then
			dtb_dir="${boot_dir}/dts"
		fi

		if use device_tree; then
			local its_script="$(cros-workon_get_build_dir)/its_script"
			emit_its_script "${its_script}" "${boot_dir}" \
				"${dtb_dir}" $(get_dtb_name "${dtb_dir}")
			mkimage -D "-I dts -O dtb -p 1024" -f "${its_script}" "${kernel_bin}" || die
		else
			cp -a "${boot_dir}/uImage" "${kernel_bin}" || die
		fi
		cp -a "${boot_dir}/zImage" "${zimage_bin}" || die

		# TODO(vbendeb): remove the below .uimg link creation code
		# after the build scripts have been modified to use the base
		# image name.
		cd $(dirname "${kernel_bin}")
		ln -sf $(basename "${kernel_bin}") vmlinux.uimg || die
		ln -sf $(basename "${zimage_bin}") zImage || die
	fi
	if [ ! -e "${D}/boot/vmlinuz" ]; then
		ln -sf "vmlinuz-${version}" "${D}/boot/vmlinuz" || die
	fi

	# Check the size of kernel image and issue warning when image size is near
	# the limit. For factory install initramfs, we don't care about kernel
	# size limit as the image is downloaded over network.
	local kernel_image_size=$(stat -c '%s' -L "${D}"/boot/vmlinuz)
	einfo "Kernel image size is ${kernel_image_size} bytes."
	if use netboot_ramfs; then
		# No need to check kernel image size.
		true
	elif [[ ${kernel_image_size} -gt $((8 * 1024 * 1024)) ]]; then
		die "Kernel image is larger than 8 MB."
	elif [[ ${kernel_image_size} -gt $((7 * 1024 * 1024)) ]]; then
		ewarn "Kernel image is larger than 7 MB. Limit is 8 MB."
	fi

	# Install uncompressed kernel for debugging purposes.
	insinto /usr/lib/debug/boot
	doins "$(cros-workon_get_build_dir)/vmlinux"

	if use kernel_sources; then
		install_kernel_sources
	else
		dosym "$(cros-workon_get_build_dir)" "/usr/src/linux"
	fi
}

EXPORT_FUNCTIONS pkg_setup src_prepare src_configure src_compile src_test src_install
