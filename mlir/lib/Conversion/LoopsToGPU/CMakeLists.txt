add_mlir_conversion_library(MLIRLoopsToGPU
  LoopsToGPU.cpp
  LoopsToGPUPass.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir/Conversion/LoopsToGPU

  DEPENDS
  MLIRConversionPassIncGen
)
target_link_libraries(MLIRLoopsToGPU
  PUBLIC
  MLIRAffine
  MLIRAffineToStandard
  MLIRGPU
  MLIRIR
  MLIRLinalgOps
  MLIRPass
  MLIRStandardOps
  MLIRSupport
  MLIRTransforms
  LLVMSupport
  )
