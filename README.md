# Karatsuba Polynomial Multiplication
## Author: Gordon Yang
## Date: 06/05/2025

## Overview
This is an implementation of the Karatsuba polynomial multiplication algorithm in the LEGv8 assembly language, a RISC ISA part of the ARM architecture family. This was done as my final project for *ECE 30: Intro to Computer Engineering* at UC San Diego, during the Spring 2025 quarter.

Given two polynomials of equal degree d, a naive algorithm can multiply them in O(d^2) time, by using a double-nested loop. However, if d is large, the runtime of the naive algorithm will require a lot of computations, and thus increase the runtime of the algorithm drastically.

In this project, we implement the Karatsuba polynomial multiplication algorithm, which efficiently multiplies two polynomials of degree d by using the divide-and-conquer technique. This takes O(d^1.58) time instead of the naive O(d^2) time. In addition, if we are given more than 2 polynomials to multiply, we utilize binary partitioning to multiply these polynomials recursively.

## Algorithms
### Two-way multiplication w/ Karatsuba's Algorithm

### Multiplication of *k* polynomials by Binary Partitioning

## Procedures
### InitZeros

### MakeCumulative

### ComputeAuxiliary

### NaiveMult

### KaratsubaMult

### BinaryPartitioning

### Main Function

## Algorithm Testing

### Input data format

### Results