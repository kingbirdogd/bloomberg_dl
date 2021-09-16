cmake_minimum_required(VERSION 3.0)
project(bloomberg_dl_soap)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17 -DWITH_OPENSSL -DHAVE_PKCS12_SUPPORT")

set(SOURCE_FILES plugin/logging.c bloomberg_dl_client.cpp soapC.cpp soapPerSecurityWSBindingProxy.cpp stdsoap2.cpp bloomberg_dl_client.h PerSecurityWSBinding.nsmap soapH.h soapPerSecurityWSBindingProxy.h  soapStub.h stdsoap2.h)
set(TARGET_FILES bloomberg_dl_test.cpp bloomberg_dl_client.h)
find_package(OpenSSL REQUIRED)
add_library(bloomberg_dl_soap STATIC ${SOURCE_FILES})
set_property(TARGET bloomberg_dl_soap  PROPERTY POSITION_INDEPENDENT_CODE ON)
add_executable(bloomberg_dl_soap_test ${TARGET_FILES})
target_link_libraries(bloomberg_dl_soap_test bloomberg_dl_soap)
target_link_libraries(bloomberg_dl_soap_test OpenSSL::Crypto)
target_link_libraries(bloomberg_dl_soap_test OpenSSL::SSL)
