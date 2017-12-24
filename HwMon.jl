module HwMon
    export  meminfo,
            cpufreq,
            cpus,
            load,
            temperatures,
            temperature_names

    function meminfo()
        return [parse(Int,split(readstring(`cat /proc/meminfo`))[i])*1024 for i in [2,5,8,11,14,56,59,17]]
    end

    function onlineparser(str)
        cpus = Int32[]
        for i in split(str,',')
            if !in('-',i)
                push!(cpus,parse(Int,i))
            else
                temp = split(i,'-')
                low = parse(Int,temp[1])
                high = parse(Int,temp[end])
                for j in low:high
                    push!(cpus,j)
                end
            end
        end
        return cpus
    end

    function cpufreq()
        onlinestr = strip(readstring(`cat /sys/devices/system/cpu/online`))
        cpus = onlineparser(onlinestr)
        freqs = Int32[]
        for i in cpus
            freqstr = "/sys/devices/system/cpu/cpu"*string(i)*"/cpufreq/scaling_cur_freq"
            push!(freqs,parse(Int,readstring(`cat $freqstr`))*1000)
        end
        return freqs
    end

    function cpus()
        onlinestr = strip(readstring(`cat /sys/devices/system/cpu/online`))
        return onlineparser(onlinestr)
    end

    function load()
        res = readstring(`uptime`)
        return float(split(strip(res),[',',':'])[end-2:end])
    end

    function temperatures()
        basedir = "/sys/devices/virtual/thermal"
        s = split(strip(readstring(`ls -1 $basedir`)),'\n')
        th_dirs=[ss for ss in s if contains(ss,"thermal_zone")]
        th = Float64[]
        for si in th_dirs
            dir = basedir*"/"*si*"/temp"
            push!(th,parse(Float64,strip(readstring(`cat $dir`)))/1000)
        end
        return th
    end

    function temperature_names()
        basedir = "/sys/devices/virtual/thermal"
        s = split(strip(readstring(`ls -1 $basedir`)),'\n')
        th_dirs=[ss for ss in s if contains(ss,"thermal_zone")]
        names = String[]
        for si in th_dirs
            dir = basedir*"/"*si*"/type"
            push!(names,strip(readstring(`cat $dir`)))
        end
        return names
    end

end
