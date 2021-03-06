#include "book.h"

#define N 52000000


__global__ void add(int *a, int *b, int *c) {

    int tid = threadIdx.x + blockIdx.x*blockDim.x; // handle the data at this index
    // printf("Block ID x=%d y=%d\n", blockIdx.x, blockIdx.y);
    // printf("Block Dim x=%d y=%d\n", blockDim.x, blockDim.y);
    // printf("Thread ID x=%d y=%d\n", threadIdx.x, threadIdx.y);
    // printf("Grid Dim x=%d y=%d\n", gridDim.x, gridDim.y);

    while (tid < N){
        c[tid] = (a[tid] + b[tid]);
        tid += blockDim.x * gridDim.x;
    }
}

__global__ void assign(int *a, int *b){
    for (int i = 0; i < N; i++){
        a[i] = i;
        b[i] = i * i;
    }
}

int main( void ){
    int *a, *b, *c;
    int *dev_a, *dev_b, *dev_c;

    a = (int *)malloc(N*sizeof(int));
    b = (int *)malloc(N*sizeof(int));
    c = (int *)malloc(N*sizeof(int));
    
    HANDLE_ERROR(cudaMalloc((void**) &dev_a, N*(sizeof(int))));
    HANDLE_ERROR(cudaMalloc((void**) &dev_b, N*(sizeof(int))));
    HANDLE_ERROR(cudaMalloc((void**) &dev_c, N*(sizeof(int))));
    HANDLE_ERROR(cudaMemset(dev_c, 0, N*sizeof(int)));


    // assign<<<1, 1>>>(dev_a, dev_b);
    TIME(
    for (int i = 0; i < N; i++){
        a[i] = i;
        b[i] = i;
    }
    )
    
    HANDLE_ERROR(cudaMemcpy(dev_a, a, N*sizeof(int), cudaMemcpyHostToDevice));
    HANDLE_ERROR(cudaMemcpy(dev_b, b, N*sizeof(int), cudaMemcpyHostToDevice));

    // dim3 grid(N,N);
    // add<<<grid, grid>>>( dev_a, dev_b, dev_c );
    TIME(
    (add<<<512,512>>>(dev_a, dev_b, dev_c));
    cudaThreadSynchronize();
    )

    TIME(
    HANDLE_ERROR(cudaMemcpy(c, dev_c, N*sizeof(int), cudaMemcpyDeviceToHost));
    )

    // display the results
    TIME(
    for (int i = 0; i < N; i++){
        // printf( "%d + %d = %d\n", a[i], b[i], c[i] );
        // if (i==10000) break;
    }
    );

    cudaFree( dev_a );
    cudaFree( dev_b );
    cudaFree( dev_c );

    free( a );
    free( b );
    free( c );

    return 0;
}
