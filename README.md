# Karatsuba Polynomial Multiplication
## Author: Gordon Yang
## Date: 06/05/2025

## Overview
This is an implementation of the Karatsuba polynomial multiplication algorithm in the LEGv8 assembly language, a RISC ISA part of the ARM architecture family. This was done as my final project for *ECE 30: Intro to Computer Engineering* at UC San Diego, during the Spring 2025 quarter.

Given two polynomials of equal degree d, a naive algorithm can multiply them in $\mathcal{O}(d^2)$ time, by using a double-nested loop. However, if d is large, the runtime of the naive algorithm will require a lot of computations, and thus increase the runtime of the algorithm drastically.

In this project, we implement the Karatsuba polynomial multiplication algorithm, which efficiently multiplies two polynomials of degree d by using the divide-and-conquer technique. This takes $\mathcal{O}(d^1.58)$ time instead of the naive $\mathcal{O}(d^2)$ time. In addition, if we are given more than 2 polynomials to multiply, we utilize binary partitioning to multiply these polynomials recursively.

## Algorithms
### Two-way multiplication w/ Karatsuba's Algorithm
For two polynomials $p(x)$ and $q(x)$, of same degree $d$, let $m = \left\lfloor{d/2}\right\rfloor$. We can write $p(x) = p_1(x) + x^m\cdot p_2(x)$ and $q(x) = q_1(x) + x^m\cdot q_2(x)$. Then, we can show that
$p(x)\cdot q(x) = (p_1(x)\cdot q_1(x)) + x^{2m}\cdot(p_2(x)\cdot q_2(x))+x^m\cdot((p_1(x)+p_2(x))\cdot(q_1(x)+q_2(x)) - (p_1(x)\cdot q_1(x)) - (p_2(x)\cdot q_2(x)))$\

This breaks the degree $d$ problem down into three subproblems of degree $d/2$ where we need to only compute $p_1(x)\cdot q_1(x)$, $p_2(x)\cdot q_2(x)$, and $(p_1(x)+p_2(x))\cdot(q_1(x)+q_2(x))$ and subtract the first and second recursions from the third term by reusing the already computed values.

### Multiplication of *k* polynomials by Binary Partitioning
We are given $k$ polynomials (for simplicity, assume $k$ is a power of 2), where each polynomial is represented by a list of their coefficients, and a separate list representing the degrees of each of the $k$ polynomials. By using binary partitioning, the list of $k$ polynomials is divided in half and recursively computed, then combined at the end to yield the final product.

## Procedures
### InitZeros
- Input: memory address (X0) and count value $d$ (X1)
- Output: sets $d+1$ elements from X0 to 0.
### MakeCumulative
- Input: memory address of an array of degrees **D**, terminating with $-1$ (X2)
- Output: replaces **D** with array of cumulative sum of elements, called **I**, and returns the number of polynomials $k$ to multiply (X3)\
Ex. **D** $= [2,2,2,-1] \implies$ **I** $= [0,3,6,-1]$ and $k = 3$ is returned through X3.

### ComputeAuxiliary
- Input: memory address of polynomial **P** (X1), degree $d$ of **P** (X2)
- Output: stores result of $p_1(x)+p_2(x)$ at memory address of given **R** (X3)
### NaiveMult

### KaratsubaMult

### BinaryPartitioning

### Main Function

## Algorithm Testing

### Input data format

### Results
