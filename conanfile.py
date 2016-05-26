from conans import ConanFile
from conans.tools import download, unzip
import os

VERSION = "0.0.4"


class CMakeForwardCache(ConanFile):
    name = "cmake-forward-cache"
    version = os.environ.get("CONAN_VERSION_OVERRIDE", VERSION)
    requires = ("cmake-include-guard/master@smspillaz/cmake-include-guard", )
    generators = "cmake"
    url = "http://github.com/polysquare/cmake-forward-cache"
    licence = "MIT"
    options = {
        "dev": [True, False]
    }
    default_options = "dev=False"

    def requirements(self):
        if self.options.dev:
            self.requires("cmake-module-common/master@smspillaz/cmake-module-common")

    def source(self):
        zip_name = "cmake-forward-cache.zip"
        download("https://github.com/polysquare/"
                 "cmake-forward-cache/archive/{version}.zip"
                 "".format(version="v" + VERSION),
                 zip_name)
        unzip(zip_name)
        os.unlink(zip_name)

    def package(self):
        self.copy(pattern="*.cmake",
                  dst="cmake/cmake-forward-cache",
                  src="cmake-forward-cache-" + VERSION,
                  keep_path=True)
