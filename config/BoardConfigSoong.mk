# Add variables that we wish to make available to soong here.
ifneq (,$(wildcard $(OUT_DIR)/.path_interposer_origpath))
ORIG_PATH := $(shell cat $(OUT_DIR)/.path_interposer_origpath)
endif
EXPORT_TO_SOONG := \
    KERNEL_ARCH \
    KERNEL_CC \
    KERNEL_CLANG_TRIPLE \
    KERNEL_BUILD_OUT_PREFIX \
    KERNEL_CROSS_COMPILE \
    KERNEL_MAKE_FLAGS \
    TARGET_KERNEL_CONFIG \
    TARGET_KERNEL_HEADERS \
    TARGET_KERNEL_SOURCE \
    MAKE_PREBUILT \
    ORIG_PATH

# Setup SOONG_CONFIG_* vars to export the vars listed above.
# Documentation here:
# https://github.com/LineageOS/android_build_soong/commit/8328367c44085b948c003116c0ed74a047237a69

SOONG_CONFIG_NAMESPACES += sparkVarsPlugin

SOONG_CONFIG_sparkVarsPlugin :=

define addVar
  SOONG_CONFIG_sparkVarsPlugin += $(1)
  SOONG_CONFIG_sparkVarsPlugin_$(1) := $$(subst ",\",$$($1))
endef

$(foreach v,$(EXPORT_TO_SOONG),$(eval $(call addVar,$(v))))

SOONG_CONFIG_NAMESPACES += sparkGlobalVars
SOONG_CONFIG_sparkGlobalVars += \
    additional_gralloc_10_usage_bits \
    bootloader_message_offset \
    has_legacy_camera_hal1 \
    ignores_ftp_pptp_conntrack_failure \
    needs_netd_direct_connect_rule \
    target_init_vendor_lib \
    target_ld_shim_libs \
    target_process_sdk_version_override \
    target_surfaceflinger_fod_lib \
    uses_camera_parameter_lib \
    target_inputdispatcher_skip_event_key

SOONG_CONFIG_NAMESPACES += sparkQcomVars
SOONG_CONFIG_sparkQcomVars += \
    legacy_hw_disk_encryption \
    should_wait_for_qsee \
    supports_extended_compress_format \
    supports_hw_fde \
    supports_hw_fde_perf \
    uses_pre_uplink_features_netmgrd \
    uses_qcom_bsp_legacy \
    uses_qti_camera_device

# Only create display_headers_namespace var if dealing with UM platforms to avoid breaking build for all other platforms
ifneq ($(filter $(UM_PLATFORMS),$(PRODUCT_BOARD_PLATFORM)),)
SOONG_CONFIG_sparkQcomVars += \
    qcom_display_headers_namespace
endif

# Set default values
BOOTLOADER_MESSAGE_OFFSET ?= 0
TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS ?= 0
TARGET_INPUTDISPATCHER_SKIP_EVENT_KEY ?= 0
TARGET_INIT_VENDOR_LIB ?= vendor_init
TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY ?= libcamera_parameters
TARGET_SURFACEFLINGER_FOD_LIB ?= surfaceflinger_fod_lib

# Soong variables
SOONG_CONFIG_sparkGlobalVars_additional_gralloc_10_usage_bits := $(TARGET_ADDITIONAL_GRALLOC_10_USAGE_BITS)
SOONG_CONFIG_sparkGlobalVars_bootloader_message_offset := $(BOOTLOADER_MESSAGE_OFFSET)
SOONG_CONFIG_sparkGlobalVars_has_legacy_camera_hal1 := $(TARGET_HAS_LEGACY_CAMERA_HAL1)
SOONG_CONFIG_sparkGlobalVars_ignores_ftp_pptp_conntrack_failure := $(TARGET_IGNORES_FTP_PPTP_CONNTRACK_FAILURE)
SOONG_CONFIG_sparkGlobalVars_needs_netd_direct_connect_rule := $(TARGET_NEEDS_NETD_DIRECT_CONNECT_RULE)
SOONG_CONFIG_sparkGlobalVars_target_init_vendor_lib := $(TARGET_INIT_VENDOR_LIB)
SOONG_CONFIG_sparkGlobalVars_target_ld_shim_libs := $(subst $(space),:,$(TARGET_LD_SHIM_LIBS))
SOONG_CONFIG_sparkGlobalVars_target_inputdispatcher_skip_event_key := $(TARGET_INPUTDISPATCHER_SKIP_EVENT_KEY)
SOONG_CONFIG_sparkGlobalVars_target_process_sdk_version_override := $(TARGET_PROCESS_SDK_VERSION_OVERRIDE)
SOONG_CONFIG_sparkGlobalVars_target_surfaceflinger_fod_lib := $(TARGET_SURFACEFLINGER_FOD_LIB)
SOONG_CONFIG_sparkGlobalVars_uses_camera_parameter_lib := $(TARGET_SPECIFIC_CAMERA_PARAMETER_LIBRARY)
SOONG_CONFIG_sparkQcomVars_legacy_hw_disk_encryption := $(TARGET_LEGACY_HW_DISK_ENCRYPTION)
SOONG_CONFIG_sparkQcomVars_should_wait_for_qsee := $(TARGET_KEYMASTER_WAIT_FOR_QSEE)
SOONG_CONFIG_sparkQcomVars_supports_extended_compress_format := $(AUDIO_FEATURE_ENABLED_EXTENDED_COMPRESS_FORMAT)
SOONG_CONFIG_sparkQcomVars_supports_hw_fde := $(TARGET_HW_DISK_ENCRYPTION)
SOONG_CONFIG_sparkQcomVars_supports_hw_fde_perf := $(TARGET_HW_DISK_ENCRYPTION_PERF)
SOONG_CONFIG_sparkQcomVars_uses_pre_uplink_features_netmgrd := $(TARGET_USES_PRE_UPLINK_FEATURES_NETMGRD)
SOONG_CONFIG_sparkQcomVars_uses_qcom_bsp_legacy := $(TARGET_USES_QCOM_BSP_LEGACY)
SOONG_CONFIG_sparkQcomVars_uses_qti_camera_device := $(TARGET_USES_QTI_CAMERA_DEVICE)
ifneq ($(filter $(QSSI_SUPPORTED_PLATFORMS),$(PRODUCT_BOARD_PLATFORM)),)
SOONG_CONFIG_sparkQcomVars_qcom_display_headers_namespace := vendor/qcom/opensource/commonsys-intf/display
else
SOONG_CONFIG_sparkQcomVars_qcom_display_headers_namespace := $(QCOM_SOONG_NAMESPACE)/display
endif

ifeq ($(TARGET_USE_QTI_BT_STACK),true)
PRODUCT_SOONG_NAMESPACES += \
    vendor/qcom/opensource/commonsys/packages/apps/Bluetooth \
    vendor/qcom/opensource/commonsys/system/bt/conf
else
PRODUCT_SOONG_NAMESPACES += packages/apps/Bluetooth
endif #TARGET_USE_QTI_BT_STACK
