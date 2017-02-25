// Homework 1
// Color to Greyscale Conversion

//A common way to represent color images is known as RGBA - the color
//is specified by how much Red, Green, and Blue is in it.
//The 'A' stands for Alpha and is used for transparency; it will be
//ignored in this homework.

//Each channel Red, Blue, Green, and Alpha is represented by one byte.
//Since we are using one byte for each color there are 256 different
//possible values for each color.  This means we use 4 bytes per pixel.

//Greyscale images are represented by a single intensity value per pixel
//which is one byte in size.

//To convert an image from color to grayscale one simple method is to
//set the intensity to the average of the RGB channels.  But we will
//use a more sophisticated method that takes into account how the eye 
//perceives color and weights the channels unequally.

//The eye responds most strongly to green followed by red and then blue.
//The NTSC (National Television System Committee) recommends the following
//formula for color to greyscale conversion:

//I = .299f * R + .587f * G + .114f * B

//Notice the trailing f's on the numbers which indicate that they are 
//single precision floating point constants and not double precision
//constants.

//You should fill in the kernel as well as set the block and grid sizes
//so that the entire image is processed.

#include "reference_calc.cpp"
#include "utils.h"
#include <stdio.h>

__global__
void rgba_to_greyscale(const uchar4* const rgbaImage,
                       unsigned char* const greyImage,
                       int numRows, int numCols)
{
  /*
   * Find the location of the image pixel
   */
  int x = (blockIdx.x * blockDim.x) + threadIdx.x; //row id of the pixel
  int y = (blockIdx.y * blockDim.y) + threadIdx.y; //column id of the pixel
  
  /*
   * Get the rgb value of original image for the location above found
   */
  uchar4 rgb_value = *(rgbaImage + (x * numCols + y));
  
  /*
   * Calculate grey scale pixel value for the same location 
   */
  unsigned char grey_value = rgb_value.x*.299f + rgb_value.y*.587f + rgb_value.z*.114f;
  
  /*
   * Save the calculated value for memory allocated of gray scale image
   */
  *(greyImage + (x * numCols + y)) = grey_value;
  
}

__global__
void lightness_rgba_to_greyscale(const uchar4* const rgbaImage,
                       unsigned char* const greyImage,
                       int numRows, int numCols)
{
  /*
   * Find the location of the image pixel
   */
  int x = (blockIdx.x * blockDim.x) + threadIdx.x; //row id of the pixel
  int y = (blockIdx.y * blockDim.y) + threadIdx.y; //column id of the pixel
  
  /*
   * Get the rgb value of original image for the location above found
   */
  uchar4 rgb_value = *(rgbaImage + (x * numCols + y));
  
  /*
   * Calculate grey scale pixel value for the same location 
   */
  unsigned char max_rgba = rgb_value.x;
  unsigned char min_rgba = rgb_value.x;
  
  if(rgb_value.y > max_rgba){
    max_rgba = rgb_value.y;
  }
  
  if(rgb_value.z > max_rgba){
    max_rgba = rgb_value.z;
  }
  
  if(rgb_value.y < min_rgba){
    min_rgba = rgb_value.y;
  }
  
  if(rgb_value.z < min_rgba){
    min_rgba = rgb_value.z;
  }
  
  unsigned char grey_value = (max_rgba + min_rgba)/2;
  
  /*
   * Save the calculated value for memory allocated of gray scale image
   */
  *(greyImage + (x * numCols + y)) = grey_value;
}

void your_rgba_to_greyscale(const uchar4 * const h_rgbaImage, uchar4 * const d_rgbaImage,
                            unsigned char* const d_greyImage, size_t numRows, size_t numCols)
{
  /*
   * Divide rows into 16 and columns into 16. 
   */ 
  int choise; 
  const dim3 blockSize(17, 17, 1);  //TODO
  const dim3 gridSize( numRows/16, numCols/16, 1);  //TODO
  rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, numRows, numCols);
  lightness_rgba_to_greyscale<<<gridSize, blockSize>>>(d_rgbaImage, d_greyImage, numRows, numCols);
  
  cudaDeviceSynchronize(); checkCudaErrors(cudaGetLastError());
}
