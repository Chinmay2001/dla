using PauliOperators
using UnitaryPruning
using Plots



# paulis = [1im * Pauli("X"), 1im*Pauli("Y")]
# paulis = [1im * Pauli("XX"), 1im * Pauli("ZI"), 1im * Pauli("IZ")]
# paulis = [1im * Pauli("X"), 1im * Pauli("Y"), 1im * Pauli("Z")]
# paulis = [1im * Pauli("IIXY"), 1im * Pauli("YYYY")]


# o = Pauli(N, Z=[1])
dla_pauli = []
sites = 30
for N in 1:sites
    global dla_pauli
    # global o
    # paulis = [1im * Pauli(N, Z = [1, 2]),1im * Pauli(N, Z = [2, 3]), 1im * Pauli(N, Z = [1, 3]), 1im * Pauli(N, X = [1]), 1im * Pauli(N, X = [2]), 1im * Pauli(N, X = [3])]

    paulis, params = UnitaryPruning.get_unitary_sequence_1D(Pauli(N, Z=[1]), α = pi/4, k = 1)
    # println(length(paulis))

    paulis = 1im * paulis

    # Making sure that all the elements in the pauli list are SKEW HERMITIAN
    for i in 1:2*N
        # global paulis
        # println(i)
        if imag(paulis[i].coeff) < 0
            paulis[i] = -paulis[i]
        end
    end

    # function dla_run(paulis)
    # println(paulis)
    pauli_strings = []

    for i in paulis
        push!(pauli_strings, i.pauli)
    end

    initial_pauli_strings = copy(pauli_strings)


    not_in_list = true

    while not_in_list
        # global pauli_strings
        # global paulis
        # global not_in_list
        com = []
        com_length = 0

        # Calculating all the possible commutators [p1, p2]
        for p1 in paulis
            for p2 in paulis
        
            temp = commutator(p1, p2)
            if length(temp) > 0
                # Storing the commutator values in com list
                push!(com, temp[1])                     
                # println("The commutator of ", p1.pauli, "and ", p2.pauli, "is ", temp[1].pauli)
                # println()

            else
                # println("The commutator of ", p1.pauli, "and ", p2.pauli, "is ", 0)
                # println()

            end

            end
        end


        # Comparing whether [p1, p2] are there in the initial pauli list
        for p in com
            if p.pauli in pauli_strings
                com_length += 1
            else
                push!(paulis, p)
                push!(pauli_strings, p.pauli)
                # println("====================================================")
                # println("Adding Pauli  ", p.pauli)
                # println(p)
                # println("====================================================")
                # println()

            end
        end

        if com_length == length(com)
            not_in_list = false
        end
    end

    final_pauli_strings = []

    for i in paulis
        push!(final_pauli_strings, i.pauli)
    end

    # println("Initial Pauli Strings \n", initial_pauli_strings, '\n')
    # println("Final Pauli Strings after DLA \n", final_pauli_strings)
    println("--------------------------------------------------------")
    println("Number of ising sites: ", N)
    println("Length of initial pauli set: ", 2*N)
    len_final = length(final_pauli_strings)
    println("Length of final pauli set after DLA: ", len_final)
    push!(dla_pauli, len_final)

end
arr_sites = [1:sites]
ini_pauli = []
for j in 1:sites
    push!(ini_pauli, 2*j)
end
# println(ini_pauli)

# plot(arr_sites, [ini_pauli dla_pauli], marker = :circle, label = ["# Initial Paulis" "# DLA Paulis"], seriestype=:scatter)
plot(arr_sites, dla_pauli, marker = :circle, label =  "# DLA Paulis", seriestype=:scatter,
title="Increase in the number of PauliOperators after DLA for $(sites) sites",titlefont=font(12,"Arial"))


xlabel!("Number of sites")
ylabel!("Number of paulis after DLA")

# titlefontsize!(5)
savefig(String("dla_vs_site_$(sites).pdf"))


# dla_run(paulis)
