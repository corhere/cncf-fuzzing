#!/bin/bash -eu
# Copyright 2023 the cncf-fuzzing authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################

# Delete build comment ("unit")
sed '1d' -i $SRC/dapr/pkg/diagnostics/diagtestutils/testutils.go

export CNCFFuzzing="${SRC}/cncf-fuzzing/projects/dapr"

printf "package expr\nimport _ \"github.com/AdamKorcz/go-118-fuzz-build/testing\"\n" > $SRC/dapr/pkg/expr/registerfuzzdep.go
go mod edit -replace github.com/adalogics/go-fuzz-headers=github.com/adamkorcz/go-fuzz-headers-1@1f10f66a31bf0e5cc26a2f4a74bd3be5f6463b67
go mod tidy
mv $SRC/dapr/pkg/actors/actors_test.go $SRC/dapr/pkg/actors/actors_test_fuzz.go
mv $SRC/dapr/pkg/actors/actor_test.go $SRC/dapr/pkg/actors/actor_test_fuzz.go

cp $CNCFFuzzing/fuzz_expr_test.go $SRC/dapr/pkg/expr/
compile_native_go_fuzzer github.com/dapr/dapr/pkg/expr FuzzExprDecodeString FuzzExprDecodeString

cp $CNCFFuzzing/fuzz_injector_test.go $SRC/dapr/pkg/injector/
compile_native_go_fuzzer github.com/dapr/dapr/pkg/injector FuzzHandleRequest FuzzHandleRequest

cp $CNCFFuzzing/fuzz_placement_raft_test.go $SRC/dapr/pkg/placement/raft/
compile_native_go_fuzzer github.com/dapr/dapr/pkg/placement/raft FuzzFSMPlacementState FuzzFSMPlacementState

mv $SRC/dapr/pkg/runtime/runtime_test.go $SRC/dapr/pkg/runtime/runtime_test_fuzz.go
cp $CNCFFuzzing/fuzz_runtime_test.go $SRC/dapr/pkg/runtime/
compile_native_go_fuzzer github.com/dapr/dapr/pkg/runtime FuzzDaprRuntime FuzzDaprRuntime

cp $CNCFFuzzing/fuzz_messaging_test.go $SRC/dapr/pkg/messaging/
mv $SRC/dapr/pkg/messaging/direct_messaging_test.go $SRC/dapr/pkg/messaging/direct_messaging_test_fuzz.go 
compile_native_go_fuzzer github.com/dapr/dapr/pkg/messaging FuzzInvokeRemote FuzzInvokeRemote

cp $CNCFFuzzing/fuzz_actors_test.go $SRC/dapr/pkg/actors/
compile_native_go_fuzzer github.com/dapr/dapr/pkg/actors FuzzActorsRuntime FuzzActorsRuntime unit
cp $CNCFFuzzing/fuzz_acl_test.go $SRC/dapr/pkg/acl/
compile_native_go_fuzzer github.com/dapr/dapr/pkg/acl FuzzParseAccessControlSpec FuzzParseAccessControlSpec

cd $SRC/kit
cp $CNCFFuzzing/fuzz_kit_crypto_test.go ./crypto
cp $CNCFFuzzing/fuzz_aescbcaead_test.go ./crypto/aescbcaead/
printf "package expr\nimport _ \"github.com/AdamKorcz/go-118-fuzz-build/testing\"\n" > $SRC/dapr/pkg/expr/registerfuzzdep.go
go mod edit -replace github.com/AdaLogics/go-fuzz-headers=github.com/AdamKorcz/go-fuzz-headers-1@1f10f66a31bf0e5cc26a2f4a74bd3be5f6463b67
go mod tidy
go get github.com/AdamKorcz/go-118-fuzz-build/testing
compile_native_go_fuzzer github.com/dapr/kit/crypto FuzzCryptoKeysJson FuzzCryptoKeysJson
compile_native_go_fuzzer github.com/dapr/kit/crypto FuzzCryptoKeysRaw FuzzCryptoKeysRaw
compile_native_go_fuzzer github.com/dapr/kit/crypto FuzzCryptoKeysAny FuzzCryptoKeys
compile_native_go_fuzzer github.com/dapr/kit/crypto FuzzSymmetric FuzzSymmetric
compile_native_go_fuzzer github.com/dapr/kit/crypto/aescbcaead FuzzAescbcaead FuzzAescbcaead

