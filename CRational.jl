import Base: ==, <, >, <=, >=, +, -, *, ÷, /
import Base: zero, one, string, show

struct CRational
    numerator::CInt
    denominator::CInt
    function CRational(numerator::CInt, denominator::CInt)
        g = gcd(numerator, denominator)
        if g != one(CInt)
            numerator = numerator÷g
            denominator = denominator÷g
        end
        return new(numerator, denominator)
    end
end
function /(num1::CInt, num2::CInt)
    return CRational(num1, num2)
end
function zero(::Type{CRational})
    return CRational(zero(CInt), one(CInt))
end
function one(::Type{CRational})
    return CRational(one(CInt), one(CInt))
end
function reciprocal(a::CRational)
    return CRational(a.denominator, a.numerator)
end
function string(a::CRational)
    s = string(a.numerator)*"/"*string(a.denominator)
    a.numerator.flag ⊻ a.denominator.flag && (s = "-"*s)
    return s
end
function show(io::IO, a::CRational)
    print(io, string(a))
end
function +(num1::CRational, num2::CRational)
    numerator = num1.numerator*num2.denominator+num1.denominator*num2.numerator
    denominator = num1.denominator*num2.denominator
    return CRational(numerator, denominator)
end
function -(num1::CRational, num2::CRational)
    numerator = num1.numerator*num2.denominator-num1.denominator*num2.numerator
    denominator = num1.denominator*num2.denominator
    return CRational(numerator, denominator)
end
function *(num1::CRational, num2::CRational)
    numerator = num1.numerator*num2.numerator
    denominator = num1.denominator*num2.denominator
    return CRational(numerator, denominator)
end
function ÷(num1::CRational, num2::CRational)
    numerator = num1.numerator*num2.denominator
    denominator = num1.denominator*num2.numerator
    return CRational(numerator, denominator)
end
