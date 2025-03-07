# Board platforms lists to be used for
# PRODUCT_BOARD_PLATFORM specific featurization
KONA := kona #SM8250
LITO := lito #SM7250
BENGAL := bengal #SM6115
MSMNILE := msmnile #SM8150
MSMSTEPPE := sm6150
TRINKET := trinket #SM6125
ATOLL := atoll #SM6250
LAHAINA := lahaina #SM8350

# A Family
QCOM_BOARD_PLATFORMS += msm7x27a
QCOM_BOARD_PLATFORMS += msm7x30
QCOM_BOARD_PLATFORMS += msm8660

QCOM_BOARD_PLATFORMS += msm8960

# B Family
QCOM_BOARD_PLATFORMS += msm8226
QCOM_BOARD_PLATFORMS += msm8610
QCOM_BOARD_PLATFORMS += msm8974

QCOM_BOARD_PLATFORMS += apq8084

# B64 Family
QCOM_BOARD_PLATFORMS += msm8992
QCOM_BOARD_PLATFORMS += msm8994

# BR Family
QCOM_BOARD_PLATFORMS += msm8909
QCOM_BOARD_PLATFORMS += msm8916

QCOM_BOARD_PLATFORMS += msm8952

# UM Family
QCOM_BOARD_PLATFORMS += msm8937
QCOM_BOARD_PLATFORMS += msm8953
QCOM_BOARD_PLATFORMS += msm8996

QCOM_BOARD_PLATFORMS += msm8998
QCOM_BOARD_PLATFORMS += sdm660

QCOM_BOARD_PLATFORMS += sdm710
QCOM_BOARD_PLATFORMS += sdm845

QCOM_BOARD_PLATFORMS += $(KONA)
QCOM_BOARD_PLATFORMS += $(LITO)
QCOM_BOARD_PLATFORMS += $(BENGAL)
QCOM_BOARD_PLATFORMS += $(TRINKET)
QCOM_BOARD_PLATFORMS += $(MSMSTEPPE)
QCOM_BOARD_PLATFORMS += $(MSMNILE)
QCOM_BOARD_PLATFORMS += $(ATOLL)
QCOM_BOARD_PLATFORMS += $(LAHAINA)

# MSM7000 Family
MSM7K_BOARD_PLATFORMS := msm7x30
MSM7K_BOARD_PLATFORMS += msm7x27
MSM7K_BOARD_PLATFORMS += msm7x27a
MSM7K_BOARD_PLATFORMS += msm7k

QSD8K_BOARD_PLATFORMS := qsd8k


# vars for use by utils
_empty :=
_space := $(_empty) $(_empty)
_colon := $(_empty):$(_empty)
_underscore := $(_empty)_$(_empty)

# $(call match-word,w1,w2)
# checks if w1 == w2
# How it works
#   if (w1-w2 not _empty or w2-w1 not _empty) then not_match else match
#
# returns true or _empty
#$(warning :$(1): :$(2): :$(subst $(1),,$(2)):) \
#$(warning :$(2): :$(1): :$(subst $(2),,$(1)):) \
#
define match-word
$(strip \
  $(if $(or $(subst $(1),$(_empty),$(2)),$(subst $(2),$(_empty),$(1))),,true) \
)
endef

# $(call find-word-in-list,w,wlist)
# finds an exact match of word w in word list wlist
#
# How it works
#   fill wlist _spaces with _colon
#   wrap w with _colon
#   search word w in list wl, if found match m, return stripped word w
#
# returns stripped word or _empty
define find-word-in-list
$(strip \
  $(eval wl:= $(_colon)$(subst $(_space),$(_colon),$(strip $(2)))$(_colon)) \
  $(eval w:= $(_colon)$(strip $(1))$(_colon)) \
  $(eval m:= $(findstring $(w),$(wl))) \
  $(if $(m),$(1),) \
)
endef

# $(call match-word-in-list,w,wlist)
# does an exact match of word w in word list wlist
# How it works
#   if the input word is not _empty
#     return output of an exact match of word w in wordlist wlist
#   else
#     return _empty
# returns true or _empty
define match-word-in-list
$(strip \
  $(if $(strip $(1)), \
    $(call match-word,$(call find-word-in-list,$(1),$(2)),$(strip $(1))), \
  ) \
)
endef

# $(call match-prefix,p,delim,w/wlist)
# matches prefix p in wlist using delimiter delim
#
# How it works
#   trim the words in wlist w
#   if find-word-in-list returns not _empty
#     return true
#   else
#     return _empty
#
define match-prefix
$(strip \
  $(eval w := $(strip $(1)$(strip $(2)))) \
  $(eval text := $(patsubst $(w)%,$(1),$(3))) \
  $(if $(call match-word-in-list,$(1),$(text)),true,) \
)
endef

# ----
# The following utilities are meant for board platform specific
# featurisation

ifndef get-vendor-board-platforms
# $(call get-vendor-board-platforms,v)
# returns list of board platforms for vendor v
define get-vendor-board-platforms
$(if $(call match-word,$(BOARD_USES_$(1)_HARDWARE),true),$($(1)_BOARD_PLATFORMS))
endef
endif # get-vendor-board-platforms

# $(call is-board-platform,bp)
# returns true or _empty
define is-board-platform
$(call match-word,$(1),$(PRODUCT_BOARD_PLATFORM))
endef

# $(call is-not-board-platform,bp)
# returns true or _empty
define is-not-board-platform
$(if $(call match-word,$(1),$(PRODUCT_BOARD_PLATFORM)),,true)
endef

# $(call is-board-platform-in-list,bpl)
# returns true or _empty
define is-board-platform-in-list
$(call match-word-in-list,$(PRODUCT_BOARD_PLATFORM),$(1))
endef

# $(call is-vendor-board-platform,vendor)
# returns true or _empty
define is-vendor-board-platform
$(strip \
  $(call match-word-in-list,$(PRODUCT_BOARD_PLATFORM),\
    $(call get-vendor-board-platforms,$(1)) \
  ) \
)
endef

# $(call is-chipset-in-board-platform,chipset)
# does a prefix match of chipset in PRODUCT_BOARD_PLATFORM
# uses _underscore as a delimiter
#
# returns true or _empty
define is-chipset-in-board-platform
$(call match-prefix,$(1),$(_underscore),$(PRODUCT_BOARD_PLATFORM))
endef

# $(call is-chipset-prefix-in-board-platform,prefix)
# does a chipset prefix match in PRODUCT_BOARD_PLATFORM
# assumes '_' and 'a' as the delimiter to the chipset prefix
#
# How it works
#   if ($(prefix)_ or $(prefix)a match in board platform)
#     return true
#   else
#     return _empty
#
define is-chipset-prefix-in-board-platform
$(strip \
  $(eval delim_a := $(_empty)a$(_empty)) \
  $(if \
    $(or \
      $(call match-prefix,$(1),$(delim_a),$(PRODUCT_BOARD_PLATFORM)), \
      $(call match-prefix,$(1),$(_underscore),$(PRODUCT_BOARD_PLATFORM)), \
    ), \
    true, \
  ) \
)
endef

#----
# The following utilities are meant for Android Code Name
# specific featurisation
#
# refer http://source.android.com/source/build-numbers.html
# for code names and associated sdk versions
CUPCAKE_SDK_VERSIONS := 3
DONUT_SDK_VERSIONS   := 4
ECLAIR_SDK_VERSIONS  := 5 6 7
FROYO_SDK_VERSIONS   := 8
GINGERBREAD_SDK_VERSIONS := 9 10
HONEYCOMB_SDK_VERSIONS := 11 12 13
ICECREAM_SANDWICH_SDK_VERSIONS := 14 15
JELLY_BEAN_SDK_VERSIONS := 16 17 18

# $(call is-platform-sdk-version-at-least,version)
# version is a numeric SDK_VERSION defined above
define is-platform-sdk-version-at-least
$(strip \
  $(if $(filter 1,$(shell echo "$$(( $(PLATFORM_SDK_VERSION) >= $(1) ))" )), \
    true, \
  ) \
)
endef

# $(call is-android-codename,codename)
# codename is one of cupcake,donut,eclair,froyo,gingerbread,icecream
# please refer the $(codename)_SDK_VERSIONS declared above
define is-android-codename
$(strip \
  $(if \
    $(call match-word-in-list,$(PLATFORM_SDK_VERSION),$($(1)_SDK_VERSIONS)), \
    true, \
  ) \
)
endef

# $(call is-android-codename-in-list,cnlist)
# cnlist is combination/list of android codenames
define is-android-codename-in-list
$(strip \
  $(eval acn := $(_empty)) \
    $(foreach \
      i,$(1),\
      $(eval acn += \
        $(if \
          $(call \
            match-word-in-list,\
            $(PLATFORM_SDK_VERSION),\
            $($(i)_SDK_VERSIONS)\
          ),\
          true,\
        )\
      )\
    ) \
  $(if $(strip $(acn)),true,) \
)
endef
