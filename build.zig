const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "png",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    if (target.result.os.tag == .linux) {
        lib.linkSystemLibrary("m");
    }

    const zlib_dep = b.dependency("zlib", .{ .target = target, .optimize = optimize });
    lib.linkLibrary(zlib_dep.artifact("z"));
    lib.addIncludePath(b.path("upstream"));
    lib.addIncludePath(b.path("include"));

    var flags = try std.BoundedArray([]const u8, 64).init(0);
    try flags.appendSlice(&.{
        "-DPNG_ARM_NEON_OPT=0",
        "-DPNG_POWERPC_VSX_OPT=0",
        "-DPNG_INTEL_SSE_OPT=0",
        "-DPNG_MIPS_MSA_OPT=0",
    });
    lib.addCSourceFiles(.{ .files = srcs, .flags = flags.slice() });

    lib.installHeader(b.path("include/pnglibconf.h"), "pnglibconf.h");
    inline for (headers) |header| {
        lib.installHeader(b.path("upstream/" ++ header), header);
    }

    b.installArtifact(lib);
}

const headers = &.{
    "png.h",
    "pngconf.h",
    "pngdebug.h",
    "pnginfo.h",
    "pngpriv.h",
    "pngstruct.h",
};

const srcs = &.{
    "upstream/png.c",
    "upstream/pngerror.c",
    "upstream/pngget.c",
    "upstream/pngmem.c",
    "upstream/pngpread.c",
    "upstream/pngread.c",
    "upstream/pngrio.c",
    "upstream/pngrtran.c",
    "upstream/pngrutil.c",
    "upstream/pngset.c",
    "upstream/pngtrans.c",
    "upstream/pngwio.c",
    "upstream/pngwrite.c",
    "upstream/pngwtran.c",
    "upstream/pngwutil.c",
};
