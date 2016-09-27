# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
#
# @ECLASS: cros-cpfe.eclass
# @MAINTAINER:
# ChromiumOS Build Team
# @BUGREPORTS:
# Please report bugs via http://crosbug.com/new (with label Area-Build)
# @VCSURL: http://git.chromium.org/gitweb/?p=chromiumos/overlays/chromiumos-overlay.git;a=blob;f=eclass/@ECLASS@
# @BLURB: helper eclass for fetching binary components from CPFE binary host.
# @DESCRIPTION:
# Binary components (especially for private usage) are usually uploaded by CPFE
# (Chrome OS Parnter Frontend, https://www.google.com/chromeos/partner/fe/ ) and
# then retrieved by writing special SRC_URI with board name and overlay path.
#
# The path format and backend for CPFE binary host has been changed several
# times, including changes in user / overlay name and the changes from BCS
# (Binary Component Server) to Google Storage.
#
# To simplify that, inherit this eclass and build a simpler SRC_URI. Example:
#  SRC_URI=${CROS_CPFE_URL}/${CROS_CPFE_BOARD_NAME}-${P}.tbz2

# @ECLASS-VARIABLE: CROS_CPFE_BOARD_OVERLAY
# @DESCRIPTION:
# Name of current board overlay. Example: overlay-variant-peach-pit-private
: ${CROS_CPFE_BOARD_OVERLAY:=${BOARD_OVERLAY##*/}}

# @ECLASS-VARIABLE: CROS_CPFE_OVERLAY_NAME
# @DESCRIPTION:
# Overlay name on CPFE binary host. Example: variant-peach-pit-private
: ${CROS_CPFE_OVERLAY_NAME:=${CROS_CPFE_BOARD_OVERLAY#overlay-}}

# @ECLASS-VARIABLE: CROS_CPFE_USER_NAME
# @DESCRIPTION:
# User name for board on CPFE binary host. Example: pit-private
: ${CROS_CPFE_USER_NAME:=${CROS_CPFE_OVERLAY_NAME#variant-*-}}

# @ECLASS-VARIABLE: CROS_CPFE_HOME
# @DESCRIPTION:
# User's home URL on CPFE binary host.
: ${CROS_CPFE_HOME:=gs://chromeos-binaries/HOME/bcs-${CROS_CPFE_USER_NAME}}

# @ECLASS-VARIABLE: CROS_CPFE_PATH
# @DESCRIPTION:
# Package directory path on CPFE binary host.
: ${CROS_CPFE_PATH:=overlay-${CROS_CPFE_OVERLAY_NAME}/${CATEGORY}/${PN}}

# @ECLASS-VARIABLE: CROS_CPFE_URL
# @DESCRIPTION:
# Complete URL for package data on CPFE binary host.
: ${CROS_CPFE_URL:=${CROS_CPFE_HOME}/${CROS_CPFE_PATH}}

# @ECLASS-VARIABLE: CROS_CPFE_BOARD_NAME
# @DESCRIPTION:
# Real name for current board. Example: pit
: ${CROS_CPFE_BOARD_NAME:=${CROS_CPFE_USER_NAME%%-*}}
