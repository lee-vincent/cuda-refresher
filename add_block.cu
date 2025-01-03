#include <iostream>
#include <math.h>
#include <cuda_profiler_api.h>


// Kernel function to add the elements of two arrays
__global__ void add(int n, float *x, float *y)
{
    int index = threadIdx.x;
    int stride = blockDim.x;
    for (int i = index; i < n; i += stride)
        y[i] = x[i] + y[i];
}

int main(void)
{
    int N = 1 << 20;
    std::cout << "N: " << N << std::endl;
    int blockSize = 256;
    std::cout << "blockSize: " << blockSize << std::endl;
    int numBlocks = (N + blockSize - 1) / blockSize;
    std::cout << "numBlocks: " << numBlocks << std::endl;

    float *x, *y;

    // Allocate Unified Memory – accessible from CPU or GPU
    cudaMallocManaged(&x, N * sizeof(float));
    cudaMallocManaged(&y, N * sizeof(float));

    // initialize x and y arrays on the host
    for (int i = 0; i < N; i++)
    {
        x[i] = 1.0f;
        y[i] = 2.0f;
    }

    cudaProfilerStart();
    add<<<1, 256>>>(N, x, y);
    cudaDeviceSynchronize();
    cudaProfilerStop();

    // Check for errors (all values should be 3.0f)
    float maxError = 0.0f;
    for (int i = 0; i < N; i++)
        maxError = fmax(maxError, fabs(y[i] - 3.0f));
    std::cout << "Max error: " << maxError << std::endl;

    // Free memory
    cudaFree(x);
    cudaFree(y);

    return 0;
}