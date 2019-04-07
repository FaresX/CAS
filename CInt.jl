import Base: ==, <, >, <=, >=, +, -, *, ÷, %
import Base: gcd, lcm
import Base: zero, one, divrem,string, show, length

const BASE = 0x10000000000000000
#定义CInt
struct CInt <: Real
    value::Vector{UInt64}
    flag::Bool
end
#CInt构造函数
function CInt(nums::String)
    qm = nums
    m = length(qm)
    nums[1] == '-' && return -CInt(nums[2:end])
    m < 20 && return CInt([parse(UInt64, nums)], false)
    store = UInt64[]
    while m >= 20
        qs, qss = qm[1:19], ""
        q, r = 0, parse(UInt128, qs)
        for i in 20:m
            qs = string(r)*qm[i]
            q, r = divrem(parse(UInt128, qs), BASE)
            qss *= string(q)
        end
        push!(store, UInt64(r))
        qm = qss
        m = length(qm)
    end
    push!(store, parse(UInt64, qm))
    return retract(CInt(reverse(store), false))
end
function CInt(value::Integer)
    CInt(string(value))
end
function zero(::Type{CInt})
    return CInt(zeros(UInt64, 1), false)
end
function one(::Type{CInt})
    return CInt(ones(UInt64, 1), false)
end
#CInt打印
function string(a::CInt)
    ten = CInt([UInt64(10)^19], false)
    numpr = abs(a)
    ext(s) = "0"^(19-length(s))*s
    pr = []
    s = ""
    q, r = divrem(numpr, ten)
    push!(pr, r.value[1])
    while q > ten
        q, r = divrem(q, ten)
        push!(pr, r.value[1])
    end
    for i in pr
        s = ext(string(i))*s
    end
    q.value[1] != 0 && (s = string(q.value[1])*s)
    q.value[1] == 0 && length(pr) == 1 && (return string(UInt64(pr[1])))
    a.flag && (s = "-"*s)
    return s
end
function show(io::IO, num::CInt)
    print(io, string(num))
end
#CInt属性获取
length(num::CInt) = length(num.value)
#CInt长度扩展
function extend(num::CInt, digits=1)
    digits == 0 && (return num)
    CInt(vcat(zeros(UInt64, digits), num.value), num.flag)
end
#CInt首零缩进
function retract(num::CInt)
    n = length(num)
    if num.value[1] == 0 && n != 1
        p = 2
        for i in 2:n-1
            num.value[i] != 0 && break
            p += 1
        end
        return CInt(num.value[p:end], num.flag)
    end
    return num
end
#相反数
function -(num::CInt)
    return CInt(num.value, !num.flag)
end
#绝对值
function abs(num::CInt)
    num.flag && return -num
    return num
end
#符号函数
function sign(num::CInt)
    return num.flag ? -1 : 1
end
#CInt等基相等
function ==(num1::CInt, num2::CInt)
    num1.flag == num2.flag && num1.value == num2.value
end
#CInt等基小于
function <(num1::CInt, num2::CInt)
    n1, n2 = length(num1), length(num2)
    @fastmath @inbounds if !num1.flag && !num2.flag
        if n1 == n2
            for i in 1:n1
                num1.value[i] == num2.value[i] && continue
                return num1.value[i] < num2.value[i]
            end
            return false
        else
            return n1 < n2
        end
    elseif !num1.flag && num2.flag
        return false
    elseif num1.flag && !num2.flag
        return true
    else
        return -num2 < -num1
    end
end
#CInt等基小于等于
function <=(num1::CInt, num2::CInt)
    num1 < num2 || num1 == num2
end
#CInt等基大于
function >(num1::CInt, num2::CInt)
    !(num1 <= num2)
end
#CInt等基大于等于
function >=(num1::CInt, num2::CInt)
    !(num1 < num2)
end
#CInt等基加法
function +(num1::CInt, num2::CInt)
    n1, n2 = length(num1), length(num2)
    @fastmath @inbounds if !num1.flag && !num2.flag
        if n1 == n2
            num3 = Vector{UInt64}(undef, n1)
            z = zero(UInt64)
            o = one(UInt64)
            r = z
            for i in n1:-1:1
                num3[i] = num1.value[i] + num2.value[i] + r
                r = num3[i] < num1.value[i] ? o : z
            end
            r == 0 && (return CInt(num3, false))
            return CInt(vcat(r, num3), false)
        elseif n1 > n2
            return num1 + extend(num2, n1-n2)
        else
            return extend(num1, n2-n1) + num2
        end
    elseif num1.flag && num2.flag
        return -(-num1+(-num2))
    elseif !num1.flag && num2.flag
        return num1-(-num2)
    else
        return num2-(-num1)
    end
end
#CInt减法
function -(num1::CInt, num2::CInt)
    n1, n2 = length(num1), length(num2)
    @fastmath @inbounds if !num1.flag && !num2.flag
        if num1 > num2
            z = zero(UInt64)
            o = one(UInt64)
            num2ext = extend(num2, n1-n2)
            num3 = Vector{UInt64}(undef, n1)
            r = z
            for i in n1:-1:1
                num3[i] = num1.value[i] - num2ext.value[i] - r
                r = num3[i] > num1.value[i] ? o : z
            end
            return retract(CInt(num3, false))
        elseif num1 == num2
            return zero(CInt)
        else
            return -(num2-num1)
        end
    elseif num1.flag && num2.flag
        return -num2-(-num1)
    elseif !num1.flag && num2.flag
        return num1+(-num2)
    else
        return -(-num1+num2)
    end
end
#CInt等基乘法
function *(num1::CInt, num2::CInt)
    num1 == zero(CInt) || num2 == zero(CInt) && (return zero(CInt))
    n1, n2 = length(num1), length(num2)
    num3 = zeros(UInt64, n1+n2)
    @fastmath @inbounds for i in n1:-1:1
        r = zero(UInt64)
        for j in n2:-1:1
            r, num3[i+j] = UInt64.(divrem(UInt128(num1.value[i])*num2.value[j]+num3[i+j]+r, BASE))
        end
        num3[i] = r
    end
    flag = num1.flag ⊻ num2.flag
    return retract(CInt(num3, flag))
end
#CInt等基除法同时得出商和余
function divrem(num1::CInt, num2::CInt)
    num2 == zero(CInt) && error("分母为0")
    @fastmath @inbounds if !num1.flag && !num2.flag
        num1 < num2 && (return zero(CInt), num1)
        num1 == num2 && (return one(CInt), zero(CInt))
        n1, n2 = length(num1), length(num2)
        if n1 == n2
            if n1 == 1
                q, r = divrem(num1.value[1], num2.value[1])
                return CInt([q], false), CInt([r], false)
            end
            ql = max(((num1.value[1]-1)*BASE+num1.value[2]+1)÷(num2.value[1]*BASE+num2.value[2]), 1)
            qr = num1.value[1]÷num2.value[1]
            for i in ql:qr
                Ci = CInt([UInt64(i)], false)
                s = num1-Ci*num2
                s < num2 && (return Ci, s)
            end
        elseif n1 == n2+1 && CInt(num1.value[1:n2], false) < num2
            num1n, num2n = num1, num2
            flag = true
            k = zero(CInt)
            if num2.value[1] < BASE÷2
                k = CInt([UInt64(BASE÷(num2.value[1]+1))], false)
                num1n, num2n = num1*k, num2*k
                flag = false
            end
            qr = min((num1n.value[1]*BASE+num1n.value[2])÷(num2n.value[1]), BASE-1)
            ql = max(qr, 3)
            for i in ql-2:qr
                Ci = CInt([UInt64(i)], false)
                s = num1n-Ci*num2n
                if s < num2n
                    flag && (return Ci, s)
                    return Ci, s÷k
                end
            end
        else
            q = Vector{UInt64}(undef, n1-n2+1)
            r = CInt(num1.value[1:n2-1], false)
            for i in n2:n1
                push!(r.value, num1.value[i])
                r = retract(r)
                qb, r = divrem(r, num2)
                q[i-n2+1] = qb.value[1]
            end
            return retract(CInt(q, false)), r
        end
    elseif num1.flag && num2.flag
        q, r = divrem(-num1, -num2)
        return q+one(CInt), -num2-r
    elseif num1.flag && !num2.flag
        q, r = divrem(-num1, num2)
        return -q-one(CInt), num2-r
    else
        q, r = divrem(num1, -num2)
        return -q, r
    end
    return zero(CInt), zero(CInt)
end
#CIntn等基除法商
÷(num1::CInt, num2::CInt) = divrem(num1, num2)[1]
#CInt等基除法余
%(num1::CInt, num2::CInt) = divrem(num1, num2)[2]
#最大共因式
function gcd(num1::CInt, num2::CInt)
    u, v = num1, num2
    r = u%v
    u = v
    v = r
    while r > zero(CInt)
        r = u%v
        u = v
        v = r
    end
    return u
end
function lcm(num1::CInt, num2::CInt)
    return num2÷gcd(num1, num2)*num1
end
#=function fftmul(num1::CInt , num2::CInt)
    n1, n2 = length(num1), length(num2)
    n1 < 4 || n2 < 4 && (return num1*num2)
    function check(n)
        k = 2
        while true
            n == 2^k && (return n)
            2^k < n < 2^(k+1) && (return 2^(k+1)-n)
            k += 1
        end
    end
    n1n, n2n = check(n1), check(n2)
    num1n, num2n = extend(num1, n1n-n1), extend(num2, n2n-n2)
    u1 = CInt(num1n.value[1:n1n÷2], false)
    u2 = CInt(num2n.value[1:n1n÷2], false)
    v1 = CInt(num1n.value[n1n÷2:end], false)
    v2 = CInt(num2n.value[n2n÷2:end], false)
end=#
