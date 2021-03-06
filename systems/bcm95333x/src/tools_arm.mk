# $Id: tools_arm.mk,v 1.2 Broadcom SDK $
# $Copyright: Copyright 2016 Broadcom Corporation.
# This program is the proprietary software of Broadcom Corporation
# and/or its licensors, and may only be used, duplicated, modified
# or distributed pursuant to the terms and conditions of a separate,
# written license agreement executed between you and Broadcom
# (an "Authorized License").  Except as set forth in an Authorized
# License, Broadcom grants no license (express or implied), right
# to use, or waiver of any kind with respect to the Software, and
# Broadcom expressly reserves all rights in and to the Software
# and all intellectual property rights therein.  IF YOU HAVE
# NO AUTHORIZED LICENSE, THEN YOU HAVE NO RIGHT TO USE THIS SOFTWARE
# IN ANY WAY, AND SHOULD IMMEDIATELY NOTIFY BROADCOM AND DISCONTINUE
# ALL USE OF THE SOFTWARE.  
#  
# Except as expressly set forth in the Authorized License,
#  
# 1.     This program, including its structure, sequence and organization,
# constitutes the valuable trade secrets of Broadcom, and you shall use
# all reasonable efforts to protect the confidentiality thereof,
# and to use this information only in connection with your use of
# Broadcom integrated circuit products.
#  
# 2.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE SOFTWARE IS
# PROVIDED "AS IS" AND WITH ALL FAULTS AND BROADCOM MAKES NO PROMISES,
# REPRESENTATIONS OR WARRANTIES, EITHER EXPRESS, IMPLIED, STATUTORY,
# OR OTHERWISE, WITH RESPECT TO THE SOFTWARE.  BROADCOM SPECIFICALLY
# DISCLAIMS ANY AND ALL IMPLIED WARRANTIES OF TITLE, MERCHANTABILITY,
# NONINFRINGEMENT, FITNESS FOR A PARTICULAR PURPOSE, LACK OF VIRUSES,
# ACCURACY OR COMPLETENESS, QUIET ENJOYMENT, QUIET POSSESSION OR
# CORRESPONDENCE TO DESCRIPTION. YOU ASSUME THE ENTIRE RISK ARISING
# OUT OF USE OR PERFORMANCE OF THE SOFTWARE.
# 
# 3.     TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL
# BROADCOM OR ITS LICENSORS BE LIABLE FOR (i) CONSEQUENTIAL,
# INCIDENTAL, SPECIAL, INDIRECT, OR EXEMPLARY DAMAGES WHATSOEVER
# ARISING OUT OF OR IN ANY WAY RELATING TO YOUR USE OF OR INABILITY
# TO USE THE SOFTWARE EVEN IF BROADCOM HAS BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGES; OR (ii) ANY AMOUNT IN EXCESS OF
# THE AMOUNT ACTUALLY PAID FOR THE SOFTWARE ITSELF OR USD 1.00,
# WHICHEVER IS GREATER. THESE LIMITATIONS SHALL APPLY NOTWITHSTANDING
# ANY FAILURE OF ESSENTIAL PURPOSE OF ANY LIMITED REMEDY.$

#
# Addresses of things unless overridden
#

ifeq ($(strip ${CFG_LITTLE}),1)
ARMEB = arm
ENDIAN_FLAG=EL
ENDIAN = little
BSPFLAGS_gnu += -DLITTLE_ENDIAN -DLE_HOST
else
ARMEB = armeb
ENDIAN_FLAG=EB
ENDIAN = big
BSPFLAGS_gnu += -DBIG_ENDIAN
endif

MACHINE	= $(shell uname -m)-unknown

#
# builds on i686 machines end up with i686-pc-linux-gnu instead
# of i686-unknown-linux-gnu, rewrite as needed.
#
ifeq ($(MACHINE),i686-unknown)
MACHINE	= i686-pc
endif

MULTILIB = mcpu-cortex-r5/mthumb

# Hurricane2: CFG_TEST_START and CFG_DATA_START will be overrided.

ifeq ($(strip ${CFG_RAMAPP}),1)
CFG_TEXT_START ?= 0x00000000
endif

CFG_DATA_START ?= 0x80000000
CFG_ROM_START  ?= 0xFFFD0000

#
# Tools locations
#

ifeq ($(strip ${CFG_GNU_TOOLCHAIN}),1)
TOOLCHAIN_DIR ?= /projects/ntsw-tools/gnu/$(MACHINE)-linux-gnu/$(ARMEB)-elf
TOOLPREFIX ?= $(ARMEB)-elf-
GCC_VERSION = 4.7.0
else
TOOLCHAIN_DIR ?= /projects/ntsw-tools/gnu/gcc-arm-none-eabi-4_8-2014q1
TOOLPREFIX ?= $(ARMEB)-none-eabi-
#GCC_VERSION = 4.8.3
GCC_VERSION = 4.7.2
endif
TOOLS ?= $(TOOLCHAIN_DIR)/bin

#
# BOOTRAM mode (runs from ROM vector assuming ROM is writable)
# implies no relocation.
#

ifeq ($(strip ${CFG_BOOTRAM}),1)
  CFG_RELOC = 0
endif


#
# Basic compiler options and preprocessor flags
#
LDFLAGS +=  -e reset -$(ENDIAN_FLAG) --gc-sections  --defsym reset_addr=$(CFG_TEXT_START) -T $(BSP_SRC)/$(LD_SCRIPT) 
LDLIBS += -lgcc

#gccincdir = $(shell $(GCC) -print-file-name=include)

# Need back here ?
#sys-include = $(gccincdir)/../../../../../arm-linux/sys-include

# Add GCC lib
#ifdef USE_PRIVATE_LIBGCC
#  ifeq ("$(USE_PRIVATE_LIBGCC)", "yes")
#    PLATFORM_LIBGCC = $(OBJTREE)/arch/$(ARCH)/lib/libgcc.o
#  else
#    PLATFORM_LIBGCC = -L $(USE_PRIVATE_LIBGCC) -lgcc
#  endif
#else
#  PLATFORM_LIBGCC = -L $(shell dirname `$(GCC) $(CFLAGS) -print-libgcc-file-name`) -lgcc
#endif

#PLATFORM_LIBS += $(PLATFORM_LIBGCC)
#PLATFORM_LIBS +=  -L$(TOOLCHAIN_DIR)/lib/gcc/arm-none-eabi/$(GCC_VERSION)/armv7-ar/thumb -lgcc
PLATFORM_LIBS += -L$(TOOLCHAIN_DIR)/lib/gcc/arm-none-eabi/4.8.3 -lgcc
export PLATFORM_LIBS

#CFLAGS += -fno-builtin -ffreestanding -nostdinc -isystem $(gccincdir) -isystem $(sys-include)
#CFLAGS += -Wall -Wstrict-prototypes -fno-stack-protector

CFLAGS += -Wall -Werror

ifeq ($(strip ${CFG_GNU_TOOLCHAIN}),1)
CFLAGS += -g -std=gnu99 -ffunction-sections -fdata-sections -msoft-float -mtpcs-frame -m$(ENDIAN)-endian -fno-builtin -fms-extensions -DTOOLCHAIN_gnu
else
#CFLAGS += -g -std=gnu99 -fpic -msingle-pic-base -mno-pic-data-is-text-relative -ffunction-sections -fdata-sections -msoft-float -mtpcs-frame -m$(ENDIAN)-endian -fno-builtin -fms-extensions
CFLAGS += -g -std=gnu99 -fpic -msingle-pic-base -ffunction-sections -fdata-sections -msoft-float -mtpcs-frame -m$(ENDIAN)-endian -fno-builtin -fms-extensions
endif

ifeq ($(strip ${CFG_GNU_TOOLCHAIN}),1)
GLD = $(TOOLS)/$(TOOLPREFIX)ld-new
GCC = $(TOOLS)/$(TOOLPREFIX)gcc-new
GAS = $(TOOLS)/$(TOOLPREFIX)as-new
GCCAS = $(TOOLS)/$(TOOLPREFIX)gcc-new
else
GLD = $(TOOLS)/$(TOOLPREFIX)ld
GCC = $(TOOLS)/$(TOOLPREFIX)gcc
GAS = $(TOOLS)/$(TOOLPREFIX)as
GCCAS = $(TOOLS)/$(TOOLPREFIX)gcc
endif
GAR = $(TOOLS)/$(TOOLPREFIX)ar
GOBJCOPY = $(TOOLS)/$(TOOLPREFIX)objcopy
GOBJDUMP = $(TOOLS)/$(TOOLPREFIX)objdump
GSTRIP = $(TOOLS)/$(TOOLPREFIX)strip
GRANLIB = $(TOOLS)/$(TOOLPREFIX)ranlib
GNM = $(TOOLS)/$(TOOLPREFIX)nm
GCXX = $(TOOLS)/$(TOOLPREFIX)g++

#
# Check for 64-bit mode
#

ifeq ($(strip ${CFG_MLONG64}),1)
  CFLAGS += -mlong64 -D__long64
endif

#
# Determine parameters for the linker script, which is generated
# using the C preprocessor.
#
# Supported combinations:
#
#  CFG_RAMAPP   CFG_UNCACHED   CFG_RELOC   Description
#    Yes        YesOrNo        MustBeNo    CFE as a separate "application"
#    No         YesOrNo        Yes         CFE relocates to RAM as firmware
#    No         YesOrNo        No          CFE runs from flash as firmware
#

# NorthStar: ./cfe.lds is dynamiclly generated

LD_SCRIPT = um_xip_pic.lds
#LDFLAGS += -g --script $(LDSCRIPT) -pie -Ttext ${CFG_TEXT_START} --stub-group-size=4
LDSCRIPT_TEMPLATE = ${BSP_SRC}/um_ldscript.template

# NorthStar: ?
ifeq ($(strip ${CFG_UNCACHED}),1)
#  GENLDFLAGS += -DCFG_RUNFROMKSEG0=0
else
#  GENLDFLAGS += -DCFG_RUNFROMKSEG0=1
endif

# NorthStar: ?
ifeq ($(strip ${CFG_RAMAPP}),1)
   GENLDFLAGS += -DCFG_RAMAPP=1
#   GENLDFLAGS += -DCFG_RUNFROMKSEG0=1
else 
 ifeq ($(strip ${CFG_RELOC}),0)
    ifeq ($(strip ${CFG_BOOTRAM}),1)
      GENLDFLAGS += -DCFG_BOOTRAM=1
    else
      GENLDFLAGS += -DCFG_BOOTRAM=0
    endif
  else
    CFLAGS += -membedded-pic -mlong-calls 
    GENLDFLAGS += -DCFG_EMBEDDED_PIC=1
    LDFLAGS +=  --embedded-relocs
  endif
endif

#
# Add GENLDFLAGS to CFLAGS (we need this stuff in the C code as well)
#

# CFLAGS += ${GENLDFLAGS}
CFLAGS += -DCFE_TEXT_START=${CFG_TEXT_START} -DCFE_DATA_START=${CFG_DATA_START}

#
# Add the text/data/ROM addresses to the GENLDFLAGS so they
# will make it into the linker script.
#

GENLDFLAGS += -DCONFIG_SYS_TEXT_BASE=${CFG_TEXT_START}
GENLDFLAGS += -DCFE_ROM_START=${CFG_ROM_START}
GENLDFLAGS += -DCFE_TEXT_START=${CFG_TEXT_START}
GENLDFLAGS += -DCFE_DATA_START=${CFG_DATA_START}

