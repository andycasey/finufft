function [c ier] = finufft1d2(x,isign,eps,f,o)
% FINUFFT1D2
%
% [c ier] = finufft1d2(x,isign,eps,f)
% [c ier] = finufft1d2(x,isign,eps,f,opts)
%
% Type-2 1D complex nonuniform FFT.
%
%    c[j] = SUM   f[k1] exp(+/-i k1 x[j])      for j = 1,...,nj
%            k1
%     where sum is over -ms/2 <= k1 <= (ms-1)/2.
%
%  Inputs:
%     x     location of NU targets on interval [-3pi,3pi], length nj
%     f     complex Fourier transform values
%     isign  if >=0, uses + sign in exponential, otherwise - sign.
%     eps    precision requested (>1e-16)
%     opts.debug: 0 (silent, default), 1 (timing breakdown), 2 (debug info).
%     opts.spread_sort: 0 (don't sort NU pts), 1 (do), 2 (auto, default)
%     opts.fftw: FFTW plan mode, 64=FFTW_ESTIMATE (default), 0=FFTW_MEASURE, etc%     opts.modeord: 0 (CMCL increasing mode ordering, default), 1 (FFT ordering)
%     opts.chkbnds: 0 (don't check NU points valid), 1 (do, default).
%     opts.upsampfac: either 2.0 (default), or 1.25 (low RAM, smaller FFT size)
%  Outputs:
%     c     complex double array of nj answers at targets
%     ier - 0 if success, else:
%           1 : eps too small
%           2 : size of arrays to malloc exceed MAX_NF
%           other codes: as returned by cnufftspread
%
% All available threads are used; control how many with maxNumCompThreads

if nargin<5, o.dummy=1; end
[ms,n_transf]=size(f);
if ms==1, warning('f must be a column vector for n_transf=1, n_transf should be the last dimension of f.'); end
p = finufft_plan(2,ms,isign,n_transf,eps,o);
p.finufft_setpts(x,[],[],[],[],[]);
[c,ier] = p.finufft_exec(f);
