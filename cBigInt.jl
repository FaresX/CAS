import Base:+, show, length

""""定义CInt"""
struct CInt <: Real
    value::Vector{Int8}
    base::Int8
end
"""CInt构函数"""
function CInt(value::String)
    n = length(value)
    num = Vector{Int8}(undef, n)
    for i in 1:n
        num[i] = parse(Int8, value[i])
    end
    CInt(num, 10)
end
function CInt(value::Integer)
    CInt(string(value))
end
"""CInt打印"""
function Base.show(io::IO, content::CInt)
    for i in content.value
        print(io, i)
    end
end
"""CInt属性获取"""
length(value::CInt) = length(value.value)
"""CInt长度扩展"""
extend(num::CInt, digits=1) = CInt(vcat(zeros(digits), num.value), num.base)
"""CInt加法"""
function +(bi1::CInt, bi2::CInt)
    bi1.base != bi2.base && error("相加的两个数应有相同的基")
    base = bi1.base
    n1 = length(bi1)
    n2 = length(bi2)
    nmax, nmin = n1, n2
    bimax, bimin = bi1, bi2
    if n1 < n2
        nmax, nmin = n2, n1
        bimax, bimin = bi2, bi1
    end
    dn = nmax - nmin
    dn != 0 && (bimin = extend(bimin, dn))
    bi3v = Vector{Int8}(undef, Base. +(nmax, 1))
    r = zero(Int8)
    for i in nmax:-1:1
        s = Base. +(bimax.value[i], bimin.value[i], r)
        r, bi3v[Base. +(i, 1)] = s < base ? (0, s) : (1, s-base)
    end
    r == 0 && (return CInt(bi3v[2:end], base))
    bi3v[1] = r
    CInt(bi3v, base)
end

a = CInt(3999999)
b = CInt(42313)
c = a + b
