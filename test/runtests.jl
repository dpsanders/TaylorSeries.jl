# Simple tests for TaylorSeries implementation
using TaylorSeries
using Base.Test

# Tests for 1-d Tylor expansions
xT(a) = Taylor([a,one(a)],15)
xT0 = Taylor(xT(0),15)
xTI = im*xT0
z = zero(xT0)
u = 1.0*one(xT0)
tol1 = eps(1.0)

@test eltype(convert(Taylor{Complex128},u)) == Complex128
@test eltype(convert(Taylor{Complex128},1)) == Complex128
@test promote(0,Taylor(1.0,0)) == (z,u)
@test eltype(promote(0,Taylor(u))[1]) == Float64
@test eltype(promote(1.0+im, z)[1]) == Complex{Float64}
@test eltype(TaylorSeries.fixshape(z,u)[1]) == Float64

@test length(Taylor(0)) == 0
@test length(TaylorSeries.fixshape(z,convert(Taylor{Int64},[0]))[1]) == 15
@test TaylorSeries.firstnonzero(xT0) == 1
@test TaylorSeries.firstnonzero(z) == z.order+1

@test u == 1
@test 0.0 == z
@test xT0.coeffs[2] == 1
@test z+1 == u
@test xT0+xT0 == 2xT0
@test xT0-xT0 == z

xsquare = Taylor([0,0,1],15)
@test xT0^0 == xT0^0.0 == one(xT0)
@test xT0*xT0 == xsquare
@test (-xT0)^2 == xsquare
@test xsquare/xT0 == xT0
@test xT0/(xT0*3) == (1/3)*u
@test xT0/3im == -xTI/3
@test 1/(1-xT0) == Taylor(ones(xT0.order+1))
@test Taylor([0,1,1])/xT0 == xT0+1
@test (xT0+im)^2 == xsquare+2im*xT0-1
@test (xT0+im)^3 == Taylor([-1im,-3,3im,1],15)
@test (xT0+im)^4 == Taylor([1,-4im,-6,4im,1],15)
@test imag(xsquare+2im*xT0-1) == 2xT0
@test (Rational(1,2)*xsquare).coeffs[3] == 1//2
@test xT0^2/xsquare == u
@test ((1+xT0)^(1/3)).coeffs[3]+1/9 <= tol1
@test 1-xsquare == (1+xT0)-xT0*(1+xT0)
@test (1-xsquare)^2 == (1+xT0)^2 * (1-xT0)^2
@test (sqrt(1+xT0)).coeffs[3] == -1/8
@test ((1-xsquare)^(1//2))^2 == 1-xsquare
@test ((1-xT0)^(1//4)).coeffs[15] == -4188908511//549755813888
@test abs(((1+xT0)^3.2).coeffs[14] + 5.4021062656e-5) < tol1

@test isapprox( rem(4.1 + xT0,4).coeffs[1], (0.1 + xT0).coeffs[1] )
@test isapprox( mod(4.1 + xT0,4).coeffs[1], (0.1 + xT0).coeffs[1] )
@test isapprox( mod2pi(2pi + 0.1 + xT0).coeffs[1], (0.1 + xT0).coeffs[1] )

@test log(exp(xsquare)) == xsquare
@test exp(log(1-xsquare)) == 1-xsquare
@test log((1-xT0)^2) == 2*log(1-xT0)
@test real(exp(xTI)) == cos(xT0)
@test imag(exp(xTI)) == sin(xT0)
@test exp(xTI') == cos(xT0)-im*sin(xT0)
@test (exp(xT0))^(2im) == cos(2xT0)+im*sin(2xT0)
@test (exp(xT0))^Taylor(-5.2im) == cos(5.2xT0)-im*sin(5.2xT0)
@test abs((tan(xT0)).coeffs[8]- 17/315) < tol1
@test abs((tan(xT0)).coeffs[14]- 21844/6081075) < tol1
@test evalTaylor(exp(Taylor([0,1],17)),1.0) == e
@test evalTaylor(exp(Taylor([0,1],1))) == 1.0
@test evalTaylor(exp(xT0),xT0^2) == exp(xT0^2)

@test deriv( exp(xT(1.0)), 5 ) == exp(1.0)
@test deriv( exp(xT(1.0pi)), 3 ) == exp(1.0pi)
@test isapprox( deriv(exp(xT(1.0pi)), 10) , exp(1.0pi) )
@test integTaylor(diffTaylor(exp(xT0)),1) == exp(xT0)
@test integTaylor(cos(xT0)) == sin(xT0)

@test_throws ErrorException 1/xT0
@test_throws ErrorException z/z
@test_throws ErrorException xT0^1.5
@test_throws ErrorException sqrt(xT0)
@test_throws ErrorException log(xT0)
@test_throws ErrorException cos(xT0)/sin(xT0)
@test_throws ErrorException deriv( exp(xT(1.0pi)), 30 )

# Tests for 1-d Tylor expansions
set_numVars(2)
set_maxOrder(17)
xTN = TaylorN([0,1,0],17)
yTN = TaylorN([0,0,1])
zN = zero(xTN)
uN = convert(TaylorN{Float64},one(yTN))

@test TaylorN(zN,5) == 0
@test TaylorN(uN) == convert(TaylorN{Complex},1)
@test get_numVars(zN) == zN.numVars
@test length(TaylorN(0,0)) == binomial( get_numVars() + get_maxOrder(), get_maxOrder(zN) )
@test eltype(convert(TaylorN{Complex128},[1])) == Complex128

@test TaylorN(1)+xTN+yTN == TaylorN([1,1,1])
@test xTN-yTN == TaylorN([0,1,-1])
@test xTN*yTN == TaylorN([0,0,0,0,1,0])
@test (1/(1-xTN)).coeffs[4] == 1.0
@test (yTN/(1-xTN)).coeffs[5] == 1.0
@test mod(1+xTN,1) == +xTN
@test (rem(1+xTN,1)).coeffs[1] == 0
@test diffTaylor(mod2pi(2pi+yTN),2) == diffTaylor(yTN,2)
@test diffTaylor(yTN) == zN

@test diffTaylor(2xTN*yTN^2,1) == 2yTN^2
@test xTN*xTN^3 == xTN^4
@test (1+xTN)^(3//2) == ((1+xTN)^0.5)^3
@test real( exp(1im * xTN)) == cos(xTN)
@test imag((exp(yTN))^(-1im)) == -sin(yTN)
@test evalTaylor(exp( xTN+yTN )) == 1
@test isapprox(evalTaylor(exp( xTN+yTN ), [1,1]), e^2)

println("    \033[32;1mSUCCESS\033[0m")

