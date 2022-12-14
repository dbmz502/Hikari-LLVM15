; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes='default<O3>' -S | FileCheck %s

; This test after a lot of cleanup should produce pick a tail-predicated 8x
; vector loop. The 8x will be more profitable, to pick a VQDMULH.s16 instruction.
; FIXME: Tailpredicate too, but not at the expense of 8x vectorized.

target datalayout = "e-m:e-p:32:32-Fi8-i64:64-v128:64:128-a:0:32-n32-S64"
target triple = "thumbv8.1m.main-arm-none-eabi"

define void @arm_mult_q15(i16* %pSrcA, i16* %pSrcB, i16 * noalias %pDst, i32 %blockSize) #0 {
; CHECK-LABEL: @arm_mult_q15(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CMP_NOT3:%.*]] = icmp eq i32 [[BLOCKSIZE:%.*]], 0
; CHECK-NEXT:    br i1 [[CMP_NOT3]], label [[WHILE_END:%.*]], label [[WHILE_BODY_PREHEADER:%.*]]
; CHECK:       while.body.preheader:
; CHECK-NEXT:    [[MIN_ITERS_CHECK:%.*]] = icmp ult i32 [[BLOCKSIZE]], 8
; CHECK-NEXT:    br i1 [[MIN_ITERS_CHECK]], label [[WHILE_BODY_PREHEADER17:%.*]], label [[VECTOR_PH:%.*]]
; CHECK:       vector.ph:
; CHECK-NEXT:    [[N_VEC:%.*]] = and i32 [[BLOCKSIZE]], -8
; CHECK-NEXT:    [[IND_END:%.*]] = and i32 [[BLOCKSIZE]], 7
; CHECK-NEXT:    [[IND_END8:%.*]] = getelementptr i16, i16* [[PSRCA:%.*]], i32 [[N_VEC]]
; CHECK-NEXT:    [[IND_END10:%.*]] = getelementptr i16, i16* [[PDST:%.*]], i32 [[N_VEC]]
; CHECK-NEXT:    [[IND_END12:%.*]] = getelementptr i16, i16* [[PSRCB:%.*]], i32 [[N_VEC]]
; CHECK-NEXT:    br label [[VECTOR_BODY:%.*]]
; CHECK:       vector.body:
; CHECK-NEXT:    [[INDEX:%.*]] = phi i32 [ 0, [[VECTOR_PH]] ], [ [[INDEX_NEXT:%.*]], [[VECTOR_BODY]] ]
; CHECK-NEXT:    [[NEXT_GEP:%.*]] = getelementptr i16, i16* [[PSRCA]], i32 [[INDEX]]
; CHECK-NEXT:    [[NEXT_GEP14:%.*]] = getelementptr i16, i16* [[PDST]], i32 [[INDEX]]
; CHECK-NEXT:    [[NEXT_GEP15:%.*]] = getelementptr i16, i16* [[PSRCB]], i32 [[INDEX]]
; CHECK-NEXT:    [[TMP0:%.*]] = bitcast i16* [[NEXT_GEP]] to <8 x i16>*
; CHECK-NEXT:    [[WIDE_LOAD:%.*]] = load <8 x i16>, <8 x i16>* [[TMP0]], align 2
; CHECK-NEXT:    [[TMP1:%.*]] = sext <8 x i16> [[WIDE_LOAD]] to <8 x i32>
; CHECK-NEXT:    [[TMP2:%.*]] = bitcast i16* [[NEXT_GEP15]] to <8 x i16>*
; CHECK-NEXT:    [[WIDE_LOAD16:%.*]] = load <8 x i16>, <8 x i16>* [[TMP2]], align 2
; CHECK-NEXT:    [[TMP3:%.*]] = sext <8 x i16> [[WIDE_LOAD16]] to <8 x i32>
; CHECK-NEXT:    [[TMP4:%.*]] = mul nsw <8 x i32> [[TMP3]], [[TMP1]]
; CHECK-NEXT:    [[TMP5:%.*]] = ashr <8 x i32> [[TMP4]], <i32 15, i32 15, i32 15, i32 15, i32 15, i32 15, i32 15, i32 15>
; CHECK-NEXT:    [[TMP6:%.*]] = tail call <8 x i32> @llvm.smin.v8i32(<8 x i32> [[TMP5]], <8 x i32> <i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767, i32 32767>)
; CHECK-NEXT:    [[TMP7:%.*]] = trunc <8 x i32> [[TMP6]] to <8 x i16>
; CHECK-NEXT:    [[TMP8:%.*]] = bitcast i16* [[NEXT_GEP14]] to <8 x i16>*
; CHECK-NEXT:    store <8 x i16> [[TMP7]], <8 x i16>* [[TMP8]], align 2
; CHECK-NEXT:    [[INDEX_NEXT]] = add nuw i32 [[INDEX]], 8
; CHECK-NEXT:    [[TMP9:%.*]] = icmp eq i32 [[INDEX_NEXT]], [[N_VEC]]
; CHECK-NEXT:    br i1 [[TMP9]], label [[MIDDLE_BLOCK:%.*]], label [[VECTOR_BODY]], !llvm.loop [[LOOP0:![0-9]+]]
; CHECK:       middle.block:
; CHECK-NEXT:    [[CMP_N:%.*]] = icmp eq i32 [[N_VEC]], [[BLOCKSIZE]]
; CHECK-NEXT:    br i1 [[CMP_N]], label [[WHILE_END]], label [[WHILE_BODY_PREHEADER17]]
; CHECK:       while.body.preheader17:
; CHECK-NEXT:    [[BLKCNT_07_PH:%.*]] = phi i32 [ [[BLOCKSIZE]], [[WHILE_BODY_PREHEADER]] ], [ [[IND_END]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    [[PSRCA_ADDR_06_PH:%.*]] = phi i16* [ [[PSRCA]], [[WHILE_BODY_PREHEADER]] ], [ [[IND_END8]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    [[PDST_ADDR_05_PH:%.*]] = phi i16* [ [[PDST]], [[WHILE_BODY_PREHEADER]] ], [ [[IND_END10]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    [[PSRCB_ADDR_04_PH:%.*]] = phi i16* [ [[PSRCB]], [[WHILE_BODY_PREHEADER]] ], [ [[IND_END12]], [[MIDDLE_BLOCK]] ]
; CHECK-NEXT:    br label [[WHILE_BODY:%.*]]
; CHECK:       while.body:
; CHECK-NEXT:    [[BLKCNT_07:%.*]] = phi i32 [ [[DEC:%.*]], [[WHILE_BODY]] ], [ [[BLKCNT_07_PH]], [[WHILE_BODY_PREHEADER17]] ]
; CHECK-NEXT:    [[PSRCA_ADDR_06:%.*]] = phi i16* [ [[INCDEC_PTR:%.*]], [[WHILE_BODY]] ], [ [[PSRCA_ADDR_06_PH]], [[WHILE_BODY_PREHEADER17]] ]
; CHECK-NEXT:    [[PDST_ADDR_05:%.*]] = phi i16* [ [[INCDEC_PTR4:%.*]], [[WHILE_BODY]] ], [ [[PDST_ADDR_05_PH]], [[WHILE_BODY_PREHEADER17]] ]
; CHECK-NEXT:    [[PSRCB_ADDR_04:%.*]] = phi i16* [ [[INCDEC_PTR1:%.*]], [[WHILE_BODY]] ], [ [[PSRCB_ADDR_04_PH]], [[WHILE_BODY_PREHEADER17]] ]
; CHECK-NEXT:    [[INCDEC_PTR]] = getelementptr inbounds i16, i16* [[PSRCA_ADDR_06]], i32 1
; CHECK-NEXT:    [[TMP10:%.*]] = load i16, i16* [[PSRCA_ADDR_06]], align 2
; CHECK-NEXT:    [[CONV:%.*]] = sext i16 [[TMP10]] to i32
; CHECK-NEXT:    [[INCDEC_PTR1]] = getelementptr inbounds i16, i16* [[PSRCB_ADDR_04]], i32 1
; CHECK-NEXT:    [[TMP11:%.*]] = load i16, i16* [[PSRCB_ADDR_04]], align 2
; CHECK-NEXT:    [[CONV2:%.*]] = sext i16 [[TMP11]] to i32
; CHECK-NEXT:    [[MUL:%.*]] = mul nsw i32 [[CONV2]], [[CONV]]
; CHECK-NEXT:    [[SHR:%.*]] = ashr i32 [[MUL]], 15
; CHECK-NEXT:    [[TMP12:%.*]] = tail call i32 @llvm.smin.i32(i32 [[SHR]], i32 32767)
; CHECK-NEXT:    [[CONV3:%.*]] = trunc i32 [[TMP12]] to i16
; CHECK-NEXT:    [[INCDEC_PTR4]] = getelementptr inbounds i16, i16* [[PDST_ADDR_05]], i32 1
; CHECK-NEXT:    store i16 [[CONV3]], i16* [[PDST_ADDR_05]], align 2
; CHECK-NEXT:    [[DEC]] = add i32 [[BLKCNT_07]], -1
; CHECK-NEXT:    [[CMP_NOT:%.*]] = icmp eq i32 [[DEC]], 0
; CHECK-NEXT:    br i1 [[CMP_NOT]], label [[WHILE_END]], label [[WHILE_BODY]], !llvm.loop [[LOOP2:![0-9]+]]
; CHECK:       while.end:
; CHECK-NEXT:    ret void
;
entry:
  %pSrcA.addr = alloca i16*, align 4
  %pSrcB.addr = alloca i16*, align 4
  %pDst.addr = alloca i16*, align 4
  %blockSize.addr = alloca i32, align 4
  %blkCnt = alloca i32, align 4
  store i16* %pSrcA, i16** %pSrcA.addr, align 4
  store i16* %pSrcB, i16** %pSrcB.addr, align 4
  store i16* %pDst, i16** %pDst.addr, align 4
  store i32 %blockSize, i32* %blockSize.addr, align 4
  %0 = bitcast i32* %blkCnt to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %0) #3
  %1 = load i32, i32* %blockSize.addr, align 4
  store i32 %1, i32* %blkCnt, align 4
  br label %while.cond

while.cond:                                       ; preds = %while.body, %entry
  %2 = load i32, i32* %blkCnt, align 4
  %cmp = icmp ugt i32 %2, 0
  br i1 %cmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %3 = load i16*, i16** %pSrcA.addr, align 4
  %incdec.ptr = getelementptr inbounds i16, i16* %3, i32 1
  store i16* %incdec.ptr, i16** %pSrcA.addr, align 4
  %4 = load i16, i16* %3, align 2
  %conv = sext i16 %4 to i32
  %5 = load i16*, i16** %pSrcB.addr, align 4
  %incdec.ptr1 = getelementptr inbounds i16, i16* %5, i32 1
  store i16* %incdec.ptr1, i16** %pSrcB.addr, align 4
  %6 = load i16, i16* %5, align 2
  %conv2 = sext i16 %6 to i32
  %mul = mul nsw i32 %conv, %conv2
  %shr = ashr i32 %mul, 15
  %call = call i32 @__SSAT(i32 %shr, i32 16)
  %conv3 = trunc i32 %call to i16
  %7 = load i16*, i16** %pDst.addr, align 4
  %incdec.ptr4 = getelementptr inbounds i16, i16* %7, i32 1
  store i16* %incdec.ptr4, i16** %pDst.addr, align 4
  store i16 %conv3, i16* %7, align 2
  %8 = load i32, i32* %blkCnt, align 4
  %dec = add i32 %8, -1
  store i32 %dec, i32* %blkCnt, align 4
  br label %while.cond

while.end:                                        ; preds = %while.cond
  %9 = bitcast i32* %blkCnt to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %9) #3
  ret void
}

declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #1

define internal i32 @__SSAT(i32 %val, i32 %sat) #2 {
entry:
  %retval = alloca i32, align 4
  %val.addr = alloca i32, align 4
  %sat.addr = alloca i32, align 4
  %max = alloca i32, align 4
  %min = alloca i32, align 4
  %cleanup.dest.slot = alloca i32, align 4
  store i32 %val, i32* %val.addr, align 4
  store i32 %sat, i32* %sat.addr, align 4
  %0 = load i32, i32* %sat.addr, align 4
  %cmp = icmp uge i32 %0, 1
  br i1 %cmp, label %land.lhs.true, label %if.end10

land.lhs.true:                                    ; preds = %entry
  %1 = load i32, i32* %sat.addr, align 4
  %cmp1 = icmp ule i32 %1, 32
  br i1 %cmp1, label %if.then, label %if.end10

if.then:                                          ; preds = %land.lhs.true
  %2 = bitcast i32* %max to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %2) #3
  %3 = load i32, i32* %sat.addr, align 4
  %sub = sub i32 %3, 1
  %shl = shl i32 1, %sub
  %sub2 = sub i32 %shl, 1
  store i32 %sub2, i32* %max, align 4
  %4 = bitcast i32* %min to i8*
  call void @llvm.lifetime.start.p0i8(i64 4, i8* %4) #3
  %5 = load i32, i32* %max, align 4
  %sub3 = sub nsw i32 -1, %5
  store i32 %sub3, i32* %min, align 4
  %6 = load i32, i32* %val.addr, align 4
  %7 = load i32, i32* %max, align 4
  %cmp4 = icmp sgt i32 %6, %7
  br i1 %cmp4, label %if.then5, label %if.else

if.then5:                                         ; preds = %if.then
  %8 = load i32, i32* %max, align 4
  store i32 %8, i32* %retval, align 4
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup

if.else:                                          ; preds = %if.then
  %9 = load i32, i32* %val.addr, align 4
  %10 = load i32, i32* %min, align 4
  %cmp6 = icmp slt i32 %9, %10
  br i1 %cmp6, label %if.then7, label %if.end

if.then7:                                         ; preds = %if.else
  %11 = load i32, i32* %min, align 4
  store i32 %11, i32* %retval, align 4
  store i32 1, i32* %cleanup.dest.slot, align 4
  br label %cleanup

if.end:                                           ; preds = %if.else
  br label %if.end8

if.end8:                                          ; preds = %if.end
  store i32 0, i32* %cleanup.dest.slot, align 4
  br label %cleanup

cleanup:                                          ; preds = %if.end8, %if.then7, %if.then5
  %12 = bitcast i32* %min to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %12) #3
  %13 = bitcast i32* %max to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %13) #3
  %cleanup.dest = load i32, i32* %cleanup.dest.slot, align 4
  switch i32 %cleanup.dest, label %unreachable [
  i32 0, label %cleanup.cont
  i32 1, label %return
  ]

cleanup.cont:                                     ; preds = %cleanup
  br label %if.end10

if.end10:                                         ; preds = %cleanup.cont, %land.lhs.true, %entry
  %14 = load i32, i32* %val.addr, align 4
  store i32 %14, i32* %retval, align 4
  br label %return

return:                                           ; preds = %if.end10, %cleanup
  %15 = load i32, i32* %retval, align 4
  ret i32 %15

unreachable:                                      ; preds = %cleanup
  unreachable
}

declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #1

attributes #0 = { nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m55" "target-features"="+armv8.1-m.main,+dsp,+fp-armv8d16,+fp-armv8d16sp,+fp16,+fp64,+fullfp16,+hwdiv,+lob,+mve,+mve.fp,+ras,+strict-align,+thumb-mode,+vfp2,+vfp2sp,+vfp3d16,+vfp3d16sp,+vfp4d16,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8sp,-fp16fml,-hwdiv-arm,-i8mm,-neon,-sb,-sha2,-vfp3,-vfp3sp,-vfp4,-vfp4sp" "unsafe-fp-math"="true" }
attributes #1 = { argmemonly nofree nosync nounwind willreturn }
attributes #2 = { alwaysinline nounwind "frame-pointer"="all" "min-legal-vector-width"="0" "no-infs-fp-math"="true" "no-nans-fp-math"="true" "no-signed-zeros-fp-math"="true" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="cortex-m55" "target-features"="+armv8.1-m.main,+dsp,+fp-armv8d16,+fp-armv8d16sp,+fp16,+fp64,+fullfp16,+hwdiv,+lob,+mve,+mve.fp,+ras,+strict-align,+thumb-mode,+vfp2,+vfp2sp,+vfp3d16,+vfp3d16sp,+vfp4d16,+vfp4d16sp,-aes,-bf16,-cdecp0,-cdecp1,-cdecp2,-cdecp3,-cdecp4,-cdecp5,-cdecp6,-cdecp7,-crc,-crypto,-d32,-dotprod,-fp-armv8,-fp-armv8sp,-fp16fml,-hwdiv-arm,-i8mm,-neon,-sb,-sha2,-vfp3,-vfp3sp,-vfp4,-vfp4sp" "unsafe-fp-math"="true" }
attributes #3 = { nounwind }
