# Investigating the Impact of Stacked vs Single Modality on Segmentation Analysis Using Transfer Learning with SegFormer
This is the repository for the final project for BME6938: Multimodal Data Mining (Spring 23) by Team Cats Can.

## Team Members
----------------
- Emma Andrews
- Ava Burgess 
- Robin Chen 
- Jennifer Cremer 
- Maegan Cremer
- Gloria Katuka

## Quick Overview
-----------------

In this project, we fine-tune a SegFormer to perform semantic segmentation on pelvis data to detect prostate and femur. [Segformer](https://huggingface.co/docs/transformers/model_doc/segformer) uses a Transformer-based architecture known as Mix-Transformer, which consists of a Transformer-based encoder and lightweight MLP decoder.

## Dataset
----------
Gold Atlas 

## Input data format
-------------------

 - ``NIfTI (.nii)``  image/label data as inputs .


## Usage
--------

```bash
./goldA_preproc.sh
```
```python
PelvicSegmentation.ipynb
```

## Environment
--------------
* Python 3.x

## Dependencies
---------------
If using on your local host system, make sure the following libraries are installed:
- ``nibabel`` (to read NIfTI files)
- ``transformers`` (to load segFormer model)
- ``datasets`` (to create datasets and get metrics for evaluation)
- ``skimmage`` (for image preprocessing)

See notebook for any additional dependencies. 

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.
