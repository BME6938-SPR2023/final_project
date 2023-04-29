#!/bin/bash
set -e
#Cats Can 
#4/15/2023

#directories
zip_d=GoldA_zip
dcm_d=GoldA_dcm
nii_d=GoldA_nii
dct_d=GoldA_dCT
mri_d=GoldA_T2
ov_d=GoldA_stack
lab_d=GoldA_label
dcm_d=GoldA_dcm
nii_d_f=GoldA_nii_filtered 

#!!!DCM2NII conversion
#Make folder if not present
[ ! -d $dcm_d ] && mkdir $dcm_d
[ ! -d $nii_d ] && mkdir $nii_d
#Unzip folders
for sub in $(ls $zip_d); do
    echo $sub
    [ ! -d $dcm_d/$sub ] && mkdir $dcm_d/$sub
    unzip $zip_d/$sub -d $dcm_d
done
#Convert from .dcm to .nii
for sub in $(ls $dcm_d); do
    [ ! -d $nii_d/$sub ] && mkdir $nii_d/$sub
    dcm2niix -i y -f %f_%p_%t -o $nii_d/$sub $dcm_d/$sub 
done

#!!! Make overlayed image
cd ${ov_d%_stack}
for i in $(ls ../$dcm_d ); do
    sub=${i%_P}
    mri=P${sub}_T2.nii
    ct=P${sub}_dCT.nii
    3dresample -master $mri -prefix P${sub}_dCT_res -input $ct
    3dcalc -a $mri -b P${sub}_dCT_res+orig -expr 0.5*a+0.5*b -prefix "P${sub}_stack_res"
    3dcopy P${sub}_stack_res+orig ../$ov_d/P${sub}_stack_res.nii
    3dcopy $ct ../GoldA_dCT/P${sub}_dCT.nii
    3dcopy $mri ../GoldA_T2/P${sub}_T2.nii
done

#!!!Label combiner
# cd $lab_d
# for i in $(ls ../$dcm_d ); do
#     #Input filenames
#     subj_name=${i%_P}
#     echo $subj_name
#     cd $subj_name #move into subject directory
#     subj_dir=$( pwd)
#     # echo `pwd`
#     #Output filename
#     opref=final_labels
#     omap=${subj_name}_${opref}.nii.gz
#     olt=${subj_name}_${opref}.niml.lt
#     #Temporary filenames
#     tpref=_tmp
#     tsum=${tpref}_0_roi_sum.nii.gz
#     tcat=${tpref}_1_roi_cat.nii.gz
#     #Find ROI
#     prostate=$(find -name "*state.nii")
#     rectum=$( find -name "*tum.nii")
#     seminal=$( find -name "*cles.nii")
#     bladder=$( find -name "*der.nii")
#     # femur=$( find -name "*mur.nii")     # echo $femur #not all femurs present, 2_10
#     #Example
#     #3dcalc -a Left_Putamen_Anterior_3mm.nii -b Left_Putamen_Posterior_3mm.nii -c Right_Putamen_Anterior_3mm.nii -d Right_Putamen_Posterior_3mm.nii -e Left_Cereb_Hand_V+VI_3mm.nii -f Right_M1_Neurology_3mm.nii -g HMAT_Left_SMA_3mm.nii -h HMAT_Right_SMA_3mm.nii -expr '(a*1)+(b*2)+(c*3)+(d*4)+(e*5)+(f*6)+(g*7)+(h*8)' -prefix roi.nii
#     #Make ROI list
#     roi_list=("$prostate" "$rectum" "$seminal" "$bladder")
#     roi_desc=("Prostate+1" "Rectum+2" "SeminalVesciles+3" "Bladder+4")
#     # echo ${roi_list[@]}
#     # echo ${roi_desc[@]}

#     #Add all ROI, look for overlap, doesn't seem to have any
#     3dMean -sum -prefix "${tsum}" ${roi_list[@]}
#     # sum_max=$( 3dinfo -dmax "${tsum}")
#     # if ( ${sum_max} > 1 ); then
#     #     echo "Overlap"
#     #     exit 1
#     # else
#     #     echo "Nice"
#     # fi
    
#     #Make invidual labels, each with a integer
#     3dTcat -prefix ${tcat} ${roi_list[@]}
#     3dTstat -argmax1 -mask ${tsum} -prefix ${omap} ${tcat}
#     @MakeLabelTabel -lab_file ${roi_desc[@]} 1 0 \
#         -labeltable ${olt} -dset ${omap}
#     rm ${tpref}*
#     echo "++ DONE!"
#     3dcopy ${omap} ../../${lab_d}s/${omap}
#     cd ..
# done

# !!! ZSlice everything
# Get full array to determine the best slice for subsequent slicing 
# cd "prostate_full"
# for stack in $(ls .); do
#     echo $stack
#     subj=${stack%.nii}
#     for i in $(seq 1 50); do
#         echo $i
#         3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
#         3dcopy ${subj}_Z${i}+orig ${subj}_Z${i}.nii
#     done
# done
# rm *.BRIK.gz
# rm *.HEAD
# cd ..

#wrong dCT
# cd "GoldA_dCT"
# for stack in $(ls .); do
#     echo $stack
#     subj=${stack%.nii}
#     for i in $(seq 1 50); do
#         echo $i
#         3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
#         3dcopy ${subj}_Z${i}+orig "../dCT_sliced/${subj}_Z${i}.nii"
#     done
# done
# rm *.BRIK.gz
# rm *.HEAD
# cd ..

#dCT redo

# cd "GoldA"
# for img in $(ls *dCT_res+orig.BRIK); do
#     echo $img;
#     img2=${img%.BRIK}
#     3dcopy $img2 ../dCT_res/${img2%+orig}.nii
# done

# cd ..


# redo labels
cd GoldA_label
for i in $(ls .); do
    echo $i
    cd $i
    subj_name=$i
    subj_dir=$( pwd)
    opref=prostate_femur
    omap=${subj_name}_${opref}.nii.gz
    olt=${subj_name}_${opref}.niml.lt
    tpref=_tmp
    tsum=${tpref}_0_roi_sum.nii.gz
    tcat=${tpref}_1_roi_cat.nii.gz
    prostate=$(find -name "*state.nii")
    femur=$( find -name "*mur.nii")
    3dcalc -a "$femur" -expr 'step(a)' -prefix femur_c.nii
    echo $femur
    femur2="femur_c.nii"
    roi_list=("$prostate" "$femur2")
    roi_desc=("Prostate+1" "Femur+2")
    3dMean -sum -prefix "${tsum}" ${roi_list[@]}
    # sum_max=$( 3dinfo -dmax "${tsum}")
    # if ( ${sum_max} > 1 ); then
    #     echo "Overlap"
    #     exit 1
    # else
    #     echo "Nice"
    # fi
    
    #Make invidual labels, each with a integer
    3dTcat -prefix ${tcat} ${roi_list[@]}
    3dTstat -argmax1 -mask ${tsum} -prefix ${omap} ${tcat}
    @MakeLabelTabel -lab_file ${roi_desc[@]} 1 0 \
        -labeltable ${olt} -dset ${omap}
    rm ${tpref}*
    echo "++ DONE!"
    3dcopy ${omap} ../../${lab_d}s/${omap}
    # cd ..

    cd ..
done

cd "dCT_res"
for stack in $(ls .); do
    echo $stack
    subj=${stack%.nii}
    for i in $(seq 1 50); do
        echo $i
        3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
        3dcopy ${subj}_Z${i}+orig "../dCT_res_sliced/${subj}_Z${i}.nii"
    done
done
rm *.BRIK.gz
rm *.HEAD
cd ..

cd "GoldA_T2"
for stack in $(ls .); do
    echo $stack
    subj=${stack%.nii}
    for i in $(seq 1 50); do
        echo $i
        3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
        3dcopy ${subj}_Z${i}+orig "../T2_sliced/${subj}_Z${i}.nii"
    done
done
rm *.BRIK.gz
rm *.HEAD
cd ..

cd "GoldA_stack"
for stack in $(ls *_stack_res.nii); do
    echo $stack
    subj=${stack%_res.nii}
    for i in $(seq 1 50); do
        echo $i
        3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
        3dcopy ${subj}_Z${i}+orig "../stacked_sliced/${subj}_Z${i}.nii"
    done
done
rm *.BRIK
rm *.HEAD
cd ..

# Zslice prostate only
# out_d="GoldA_ZSliceSelection"
# for sub in $(ls GoldA_label ); do
    # echo $sub
    # prost=$(find GoldA_label/$sub/ -name "*state.nii")
    # echo $prost
    # cp $prost prostate_full/${sub}_prostate.nii
#     case "$sub" in 
#         *1_01*)
#         slice=33 ;;
#         *1_02*)
#         slice=48 ;;
#         *1_03*)
#         slice=38 ;;
#         *1_04*)
#         slice=34 ;;
#         *1_05*)
#         slice=38 ;;
#         *1_06*)
#         slice=36 ;;
#         *1_07*)
#         slice=37 ;;
#         *1_08*)
#         slice=35 ;;
#         *2_03*)
#         slice=46 ;;
#         *2_04*)
#         slice=41 ;;
#         *2_05*)
#         slice=50 ;;
#         *2_06*)
#         slice=45 ;;
#         *2_09*)
#         slice=50 ;;
#         *2_10*)
#         slice=42 ;;
#         *2_11*)
#         slice=50 ;;
#         *3_01*)
#         slice=39 ;;
#         *3_02*)
#         slice=36 ;;
#         *3_03*)
#         slice=46 ;;
#         *3_04*)
#         slice=30 ;;
#     esac
#     3dZcutup -keep $slice $slice -prefix ${sub}_Z${slice} $prost
#     3dcopy ${sub}_Z${slice}+orig "$out_d/prostate/${sub}_Z${slice}.nii"
# done

#!!! ZSlice selection 2
# out_d="GoldA_ZSliceSelection"
#@DCT
# cd $dct_d
# for i in $(ls .); do
    # echo $i
#     subj=${i%_dCT.nii}
#     subj=${subj#P}
#     echo $subj
#     case "$i" in 
#         *1_01*)
#         slice=33 ;;
#         *1_02*)
#         slice=48 ;;
#         *1_03*)
#         slice=38 ;;
#         *1_04*)
#         slice=34 ;;
#         *1_05*)
#         slice=38 ;;
#         *1_06*)
#         slice=36 ;;
#         *1_07*)
#         slice=37 ;;
#         *1_08*)
#         slice=35 ;;
#         *2_03*)
#         slice=46 ;;
#         *2_04*)
#         slice=41 ;;
#         *2_05*)
#         slice=50 ;;
#         *2_06*)
#         slice=45 ;;
#         *2_09*)
#         slice=50 ;;
#         *2_10*)
#         slice=42 ;;
#         *2_11*)
#         slice=50 ;;
#         *3_01*)
#         slice=39 ;;
#         *3_02*)
#         slice=36 ;;
#         *3_03*)
#         slice=46 ;;
#         *3_04*)
#         slice=30 ;;
#     esac
#     3dZcutup -keep $slice $slice -prefix ${subj}_Z${slice} $i
#     3dcopy ${subj}_Z${slice}+orig "../$out_d/dCT/${subj}_Z${slice}.nii"
# done
# rm *.BRIK
# rm *.HEAD
# cd ..

#@t2
# cd $mri_d
# for i in $(ls .); do
#     echo $i
#     subj=${i%_T2.nii}
#     subj=${subj#P}
#     echo $subj
#     case "$i" in 
#         *1_01*)
#         slice=33 ;;
#         *1_02*)
#         slice=48 ;;
#         *1_03*)
#         slice=38 ;;
#         *1_04*)
#         slice=34 ;;
#         *1_05*)
#         slice=38 ;;
#         *1_06*)
#         slice=36 ;;
#         *1_07*)
#         slice=37 ;;
#         *1_08*)
#         slice=35 ;;
#         *2_03*)
#         slice=46 ;;
#         *2_04*)
#         slice=41 ;;
#         *2_05*)
#         slice=50 ;;
#         *2_06*)
#         slice=45 ;;
#         *2_09*)
#         slice=50 ;;
#         *2_10*)
#         slice=42 ;;
#         *2_11*)
#         slice=50 ;;
#         *3_01*)
#         slice=39 ;;
#         *3_02*)
#         slice=36 ;;
#         *3_03*)
#         slice=46 ;;
#         *3_04*)
#         slice=30 ;;
#     esac
#     3dZcutup -keep $slice $slice -prefix ${subj}_Z${slice} $i
#     3dcopy ${subj}_Z${slice}+orig "../$out_d/T2/${subj}_Z${slice}.nii"
# done
# rm *.BRIK
# rm *.HEAD
# cd ..

#@labels
# cd ${lab_d}s
# for i in $(ls .); do
#     echo $i
#     subj=${i%_final_labels.nii.gz}
#     # subj=${subj#P}
#     echo $subj
#     case "$i" in 
#         *1_01*)
#         slice=33 ;;
#         *1_02*)
#         slice=48 ;;
#         *1_03*)
#         slice=38 ;;
#         *1_04*)
#         slice=34 ;;
#         *1_05*)
#         slice=38 ;;
#         *1_06*)
#         slice=36 ;;
#         *1_07*)
#         slice=37 ;;
#         *1_08*)
#         slice=35 ;;
#         *2_03*)
#         slice=46 ;;
#         *2_04*)
#         slice=41 ;;
#         *2_05*)
#         slice=50 ;;
#         *2_06*)
#         slice=45 ;;
#         *2_09*)
#         slice=50 ;;
#         *2_10*)
#         slice=42 ;;
#         *2_11*)
#         slice=50 ;;
#         *3_01*)
#         slice=39 ;;
#         *3_02*)
#         slice=36 ;;
#         *3_03*)
#         slice=46 ;;
#         *3_04*)
#         slice=30 ;;
#     esac
#     3dZcutup -keep $slice $slice -prefix ${subj}_Z${slice} $i
#     3dcopy ${subj}_Z${slice}+orig "../$out_d/labels/${subj}_Z${slice}.nii"
# done
# rm *.BRIK.gz
# rm *.HEAD.gz
# cd ..


#NO GO, everything below is trash
#works but needs fine tunning with proper registration and alignment
# cd "MakeT2avg"
#Resample T2 to match the first subject
# fname=P2_03_T2.nii
# 3dresample -master P1_01_T2.nii -prefix ${fname%.nii}b.nii -input ${fname}
# a=P1_01_T2.nii
# b=P1_02_T2b.nii
# c=P1_03_T2b.nii
# d=P1_04_T2b.nii
# e=P1_05_T2b.nii
# f=P1_06_T2b.nii
# g=P1_07_T2b.nii
# h=P1_08_T2b.nii
# i=P2_03_T2b.nii
# j=P2_04_T2b.nii
# k=P2_05_T2b.nii
# l=P2_06_T2b.nii
# m=P2_09_T2b.nii
# n=P2_10_T2b.nii
# o=P2_11_T2b.nii
# p=P3_01_T2b.nii
# q=P3_02_T2b.nii
# r=P3_03_T2b.nii
# s=P3_04_T2b.nii
# 3dcalc -a $a -b $b -c $c -d $d -e $e -f $f -g $g -h $h -i $i -j $j -k $k -l $l -m $m \
#     -n $n -o $o -p $p -q $q -r $r -s $s -expr '((a+b+c+d+e+f+g+h+i+j+k+l+m+n+o+p+q+r+s)/19)' -prefix GoldA_mean
# cd ..
#Everything above is not used


#Test Set
#@@@ Combine prostate images 
# cd "Task05_Prostate"
#Merge prostate labels
# for pro in $(ls labelsTr); do
#     echo labelsTr/$pro
#     3dcalc -a labelsTr/$pro -expr 'step(a)' -prefix labels_combinedTr/${pro%.nii.gz}_combined.nii.gz
# done

Slice stack selection for 
cd "imagesTr"
for stack in $(ls .); do
    echo $stack
    subj=${stack%.nii.gz}
    for i in $(seq 1 50); do
        echo $i
        3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
        3dcopy ${subj}_Z${i}+orig "../imagesTr_sliced/${subj}_Z${i}.nii"
    done
done
rm *.BRIK*
rm *.HEAD*
cd ..

# cd "labels_combinedTr"
# for stack in $(ls .); do
#     echo $stack
#     subj=${stack%ombined.nii.gz}
#     for i in $(seq 1 50); do
#         echo $i
#         3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
#         3dcopy ${subj}_Z${i}+orig "../labels_cTr_sliced/${subj}_Z${i}.nii"
#     done
# done
# # rm *.BRIK*
# # rm *.HEAD*
# cd ..

# cd "labels_combinedTr"
# p0="prostate_00_combined.nii.gz"
# for i in $(seq 1 50); do
#     echo $i
#     # 3dZcutup -keep $i $i -prefix "prostate_00_c_Z${i}" $p0
#     saved="prostate_00_c_Z${i}+orig"
#     3dcopy $saved "../labels_cTr_sliced/prostate_00_c_Z${i}.nii"
# done

# for prostate in $(ls prostate_00*); do 
#     echo $prostate
#     3dcopy $prostate ../labels_cTr/sliced${prostate%+orig.HEAD}.nii
# done




# cd "prostate_femur"
# for stack in $(ls .); do
#     echo $stack
#     subj=${stack%.nii.gz}
#     for i in $(seq 1 50); do
#         echo $i
#         3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
#         3dcopy ${subj}_Z${i}+orig "../prostate_femur_sliced/${subj}_Z${i}.nii"
#     done
# done
# rm *.BRIK*
# rm *.HEAD*
# cd ..

# cd "dCt2"
# for stack in $(ls .); do
#     echo $stack
#     subj=${stack%.nii}
#     for i in $(seq 1 50); do
#         echo $i
#         3dZcutup -keep $i $i -prefix ${subj}_Z${i} $stack
#         3dcopy ${subj}_Z${i}+orig "../dCt2_sliced/${subj}_Z${i}.nii"
#     done
# done
# rm *.BRIK*
# rm *.HEAD*
# cd ..