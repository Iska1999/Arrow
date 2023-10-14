# Some notes concerning RISC-V "V" and the EPI intrinsics

**TODO** : Rewrite part of the documentation

## General RISC-V "V" extension information

- There are 32 vector registers of length VLEN bits
- Each vector element contains elements of ELEN bits
- Thus, each vector can hold VLEN/ELEN elements
- Using LMUL (Length Multiplier) allows us to group vector registers
  - For example : LMUL = 1 (No grouping, 32 regvec); LMUL = 2 (groups of two, 16 regvec)...

## EPI Specifics (currently supports RVV v0.9)

- Link to the [EPI Built-in Reference](https://repo.hca.bsc.es/gitlab/rferrer/epi-builtins-ref/-/blob/master/epi-builtins-ref.md).

- EPI enforces ELEN = 64; thus the number of elements is VLEN/64
- We must use LMUL to modify VLEN, and thus the number of elements stored in the 'group'
- The syntax of vector types is `__epi_<factor>x<ty>`
  - `Factor` is the relative number of elements according to VLEN/ELEN (1,2,4,8,16,32,64)
  - `ty` is the element type (`f64` (double), `f32` (float), `i64`,` i32`, `i16`,` i8`)
- Mask types are unrelated to LMUL, as in they always use a single vector register
  - We can however set the factor value in EPI intrinsics
  - Their syntax of vector masks is `__epi_<factor>xi1` ; with factor being one of (1,2,4,8,16,32,64) __
  - A relational operation between two `__epi_2x<ty>` will generate a `__epi_2xi1` mask for example

- We can use tuples to represent pair of vectors. Currently tuples of LMUL=1 are implemented
- Their syntax is `__epi_<factor>x<ty>x2`
- To access the contents of a tuple, use the fields v0 and v1

- Documentation for mixed types is available, but we won't look into it much, as we assume, we are only dealing with integer values.

- Vector Configuration
  - Builtins can be used to set a granted vector length (gvl), given rvl/sew/lmul
  - rvl is the requested vector length
  - sew is the single element width
  - lmul is the length multiplier

- Valid sew parameters in EPI intrinsics are : 
  - `__epi_e8 `(char; signed char; unsigned char); 
  - `epi_e16` (short; unsigned short; float16); 
  - `epi_e32` (int; unsigned int; float); 
  - `__epi_e64` (long; unsigned long; double)

- Valid lmul parameters are
  - `__epi_m1` for LMUL=1
  - `__epi_m2` for LMUL=2
  - `__epi_m4` for LMUL=4
  - ` __epi_m8` for LMUL=8

- `vsetvli` instruction
  - Changes the granted vector length, returns the granted vector length `gvl`

```c
unsigned long int __builtin_epi_vsetvl(unsigned long int rvl, constant unsigned long int sew, constant unsigned long int lmul); 
```

- `vsetvlmax` EPI-specific function
  - Changes the granted vector length to the maximum length possible, returns the granted vector length `gvl`

```c
unsigned long int
__builtin_epi_vsetvlmax( 'constant'  unsigned long int sew,
                        'constant'  unsigned long int lmul);
```