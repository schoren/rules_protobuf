load("//bzl:protoc.bzl", "EXECUTABLE", "implement")
load("//bzl:util.bzl", "invoke")
load("//bzl:cpp/class.bzl", CPP = "CLASS")

cc_proto_compile = implement(["cpp"])

def cc_proto_library(
    name,
    protos = [],
    lang = CPP,
    srcs = [],
    imports = [],
    visibility = None,
    testonly = 0,
    protoc_executable = EXECUTABLE,
    protobuf_plugin_options = [],
    protobuf_plugin_executable = None,
    grpc_plugin_executable = None,
    grpc_plugin_options = [],
    descriptor_set = None,
    verbose = True,
    with_grpc = False,
    deps = [],
    hdrs = [],
    **kwargs):

  self = {
    "protos": protos,
    "with_grpc": with_grpc,
    "outs": [],
  }

  print("self %s" % self)

  invoke("build_generated_filenames", lang, self)


  cc_proto_compile(
    name = name + "_pb",
    protos = protos,
    outs = self["outs"],
    gen_cpp = True,
    gen_grpc_cpp = with_grpc,
    protoc = protoc_executable,
    verbose = 1,
  )

  cc_deps = [str(Label(dep)) for dep in getattr(lang.protobuf, "compile_deps", [])]
  if with_grpc:
    cc_deps += [str(Label(dep)) for dep in getattr(lang.grpc, "compile_deps", [])]

  #print("hdrs: $location(%s)" % result.hdrs)

  native.cc_library(
    name = name,
    srcs = srcs + self["outs"],
    deps = deps + cc_deps,
    #hdrs = result.hdrs + hdrs,
    **kwargs
  )
