#!/usr/bin/env bash
# Copyright(c) The Maintainers of Nanvix.
# Licensed under the MIT License.
#
# Cross-compile rapidfuzz C++ extensions for Nanvix (i686).
# Produces dist/librapidfuzz.a containing all extension modules.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DIST_DIR="$SCRIPT_DIR/dist"

TOOLCHAIN="${NANVIX_TOOLCHAIN:-/opt/nanvix}"
CXX="${TOOLCHAIN}/bin/i686-nanvix-g++"
AR="${TOOLCHAIN}/bin/i686-nanvix-ar"

CPYTHON_HEADERS="$SCRIPT_DIR/cpython-headers"

CXXFLAGS="-O2 -fPIC -std=c++17 -DNDEBUG -fpermissive"
CXXFLAGS="$CXXFLAGS -I${CPYTHON_HEADERS}"
CXXFLAGS="$CXXFLAGS -I${REPO_ROOT}/src/rapidfuzz"
CXXFLAGS="$CXXFLAGS -I${REPO_ROOT}/extern/rapidfuzz-cpp/rapidfuzz"

mkdir -p "$DIST_DIR/obj"

echo "[rapidfuzz] Cross-compiling C++ extensions for i686-nanvix..."

# Compile each extension module
SOURCES=(
    "$REPO_ROOT/src/rapidfuzz/utils.cpp"
    "$REPO_ROOT/src/rapidfuzz/fuzz.cpp"
    "$REPO_ROOT/src/rapidfuzz/fuzz_sse2.cpp"
    "$REPO_ROOT/src/rapidfuzz/FeatureDetector/CpuInfo.cpp"
    "$REPO_ROOT/src/rapidfuzz/distance/_initialize.cpp"
    "$REPO_ROOT/src/rapidfuzz/distance/metrics.cpp"
    "$REPO_ROOT/src/rapidfuzz/distance/metrics_sse2.cpp"
)

for src in "${SOURCES[@]}"; do
    if [ -f "$src" ]; then
        obj="$DIST_DIR/obj/$(basename "${src%.cpp}.o")"
        echo "  CC $src"
        $CXX $CXXFLAGS -c "$src" -o "$obj"
    else
        echo "  SKIP $src (not found)"
    fi
done

echo "[rapidfuzz] Creating static archive..."
$AR rcs "$DIST_DIR/librapidfuzz.a" "$DIST_DIR"/obj/*.o

echo "[rapidfuzz] Done: $DIST_DIR/librapidfuzz.a"
ls -la "$DIST_DIR/librapidfuzz.a"
