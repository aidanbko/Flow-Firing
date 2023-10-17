using DataStructures
using Primes

function endConfigurationsCount(n::Int)
    boardLength = 2 * ceil(Int, sqrt(0.25 + 2 * n) - 0.5) - 1
    startingBoard = zeros(Int8, boardLength, boardLength)
    startingBoard[ceil(Int, boardLength ^ 2 / 2)] = n

    primeMatrix = generatePrimes(boardLength)

    terminatedConfigs = Set{UInt128}()
    intermediateConfigs = Set{UInt128}()
    boardsToFire = Queue{Matrix{Int8}}()
    valuesToFire = Queue{UInt128}()
    
    enqueue!(boardsToFire, startingBoard)
    enqueue!(valuesToFire, primeMatrix[ceil(UInt128, boardLength ^ 2 / 2)] ^ (n - 1))
    
    while (! isempty(boardsToFire))

        board = dequeue!(boardsToFire)
        value = dequeue!(valuesToFire)

        isTerminated = true
    
        for i in eachindex(board)

            if (board[i] <= 1)
                continue
            end

            function enqueueIfNotDuplicate(from::Int, to::Int)
                if (board[from] > board[to] + 1) # Criteria for firing
                    isTerminated = false
                    newValue = (value ÷ primeMatrix[from]) * primeMatrix[to]
                    oldSize = length(intermediateConfigs)
                    # Attempt to add newValue to interims
                    push!(intermediateConfigs, newValue)
                    # If true, then the firing result is not a duplicate, so add it to the queue
                    if (oldSize != length(intermediateConfigs))
                        newBoard = copy(board)
                        newBoard[from] -= 1
                        newBoard[to] += 1

                        enqueue!(boardsToFire, newBoard)
                        enqueue!(valuesToFire, newValue)
                    end
                end
            end

            enqueueIfNotDuplicate(i, i - size(board, 1)) # Above
            enqueueIfNotDuplicate(i, i + size(board, 1)) # Below
            enqueueIfNotDuplicate(i, i - 1) # Left
            enqueueIfNotDuplicate(i, i + 1) # Right
        end

        if (isTerminated)
            push!(terminatedConfigs, value)
        end

    end

    return length(terminatedConfigs)
end

function generatePrimes(boardLength::Int)

    primeMatrix = zeros(UInt128, boardLength, boardLength)
    positions = Queue{Int}()
    primeMatrix[ceil(Int, size(primeMatrix, 1) ^ 2 / 2)] = 2
    enqueue!(positions, ceil(Int, size(primeMatrix, 1) ^ 2 / 2))
    p = 3

    while (! isempty(positions))
        i = dequeue!(positions)

        # If the index borders the left or right boundary, continue
        if (i % size(primeMatrix, 1) == 0 || i % size(primeMatrix, 1) == 1)
            continue
        end

        # Same but for top and bottom boundary
        if (i < size(primeMatrix, 1) || i  + size(primeMatrix, 1) > size(primeMatrix, 1) ^ 2)
            continue
        end

        function fillPositionIfEmpty(i)
            if (primeMatrix[i] == 0)
                primeMatrix[i] = p
                p = Primes.nextprime(p, 2)
                enqueue!(positions, i)
            end
        end

        fillPositionIfEmpty(i - size(board, 1)) # Above
        fillPositionIfEmpty(i + size(board, 1)) # Below
        fillPositionIfEmpty(i - 1) # Left
        fillPositionIfEmpty(i + 1) # Right
    end

    return primeMatrix
end

for n in 1:13
    @time println("n=", n, " ", endConfigurationsCount(n))
end