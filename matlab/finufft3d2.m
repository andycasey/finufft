function [c ier] = finufft3d2(x,y,z,isign,eps,f,o)
% FINUFFT3D2
%
% [c ier] = finufft3d2(x,y,z,isign,eps,f)
% [c ier] = finufft3d2(x,y,z,isign,eps,f,opts)
%
% Type-2 3D complex nonuniform FFT.
%
%    c[j] =   SUM   f[k1,k2,k3] exp(+/-i (k1 x[j] + k2 y[j] + k3 z[j]))
%           k1,k2,k3
%                            for j = 1,..,nj
%     where sum is over -ms/2 <= k1 <= (ms-1)/2, -mt/2 <= k2 <= (mt-1)/2,
%                       -mu/2 <= k3 <= (mu-1)/2.
%
%  Inputs:
%     x,y,z location of NU targets on cube [-3pi,3pi]^3, each length nj
%     f     size (ms,mt,mu) complex Fourier transform value matrix
%           (ordering given by opts.modeord in each dimension; ms fastest to mu
%            slowest).
%     isign  if >=0, uses + sign in exponential, otherwise - sign.
%     eps    precision requested (>1e-16)
%     opts.debug: 0 (silent, default), 1 (timing breakdown), 2 (debug info).
%     opts.spread_sort: 0 (don't sort NU pts), 1 (do), 2 (auto, default)
%     opts.fftw: FFTW plan mode, 64=FFTW_ESTIMATE (default), 0=FFTW_MEASURE, etc
%     opts.modeord: 0 (CMCL increasing mode ordering, default), 1 (FFT ordering)
%     opts.chkbnds: 0 (don't check NU points valid), 1 (do, default).
%     opts.upsampfac: either 2.0 (default), or 1.25 (low RAM, smaller FFT size)
%  Outputs:
%     c     complex double array of nj answers at the targets.
%     ier - 0 if success, else:
%           1 : eps too small
%           2 : size of arrays to malloc exceed MAX_NF
%           other codes: as returned by cnufftspread
%
% All available threads are used; control how many with maxNumCompThreads

if nargin<7, o.dummy=1; end
[ms,mt,mu,n_transf] = size(f);
nj=numel(x);
if numel(y)~=nj, error('y must have the same number of elements as x'); end
if numel(z)~=nj, error('z must have the same number of elements as x'); end
if ms==1, warning('f must be a column vector for n_transf=1, n_transf should be the last dimension of f.'); end
p = finufft_plan(2,[ms;mt;mu],isign,n_transf,eps,o);
p.finufft_setpts(x,y,z,[],[],[]);
[c,ier] = p.finufft_exec(f);
