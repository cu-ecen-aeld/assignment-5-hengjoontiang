################################################################################
#
# scull
#
################################################################################
AESDCHAR_VERSION='1.0'

AESDCHAR_SITE = '../assignments-3-and-later-hengjoontiang/'
AESDCHAR_SITE_METHOD = local
AESDCHAR_MODULE_SUBDIRS=aesd-char-driver

$(eval $(kernel-module))
$(eval $(generic-package))


