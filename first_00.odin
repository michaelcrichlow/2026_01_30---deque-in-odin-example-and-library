package test

import "core:fmt"
import "core:sys/windows"
import "core:time"
import p_deque "python_deque_functions"
print :: fmt.println

main :: proc() {
    print("Hello from Odin!")
    windows.SetConsoleOutputCP(windows.CODEPAGE.UTF8)
    start: time.Time = time.now()

    // code goes here

    // --- PART 1: Growth and Basic Ops ---
    q1: p_deque.Deque(string)
    p_deque.deque_init(&q1, initial_capacity = 4)
    defer p_deque.delete_deque(&q1)

    fmt.println("--- Test 1: Basic Append and Pop ---")
    p_deque.append(&q1, "A")
    p_deque.append(&q1, "B")
    p_deque.append(&q1, "C")
    
    val, _ := p_deque.pop_left(&q1)
    fmt.printf("Pop Left (Expected A): %v\n", val)

    fmt.println("\n--- Test 2: Growth & Unwrapping ---")
    p_deque.append(&q1, "D")
    p_deque.append(&q1, "E") 
    p_deque.append(&q1, "F") // Hits cap 4, triggers _grow to 8
    
    fmt.printf("Count after growth (Expected 5): %v\n", q1.count)
    fmt.printf("New Capacity (Expected 8): %v\n", q1.capacity)
    fmt.print("Current State: ")
    p_deque.print_deque(&q1) // Expected: [B, C, D, E, F]

    // --- PART 2: Search, Rotation, and Reverse ---
    fmt.println("\n--- Test 3: Rotation (Positive & Negative) ---")
    // Start: [B, C, D, E, F]
    p_deque.rotate(&q1, 2)
    fmt.print("After rotate(2) (Expected [E, F, B, C, D]): ")
    p_deque.print_deque(&q1)

    p_deque.rotate(&q1, -1)
    fmt.print("After rotate(-1) (Expected [F, B, C, D, E]): ")
    p_deque.print_deque(&q1)

    fmt.println("\n--- Test 4: Reverse ---")
    p_deque.reverse(&q1)
    fmt.print("After reverse (Expected [E, D, C, B, F]): ")
    p_deque.print_deque(&q1)

    // --- PART 3: Data Removal and Statistics ---
    fmt.println("\n--- Test 5: Count & Index ---")
    p_deque.append(&q1, "E") // Add another E
    fmt.printf("Count of 'E' (Expected 2): %v\n", p_deque.count(&q1, "E"))
    
    idx, _ := p_deque.index(&q1, "C")
    fmt.printf("Index of 'C' (Expected 2): %v\n", idx)

    fmt.println("\n--- Test 6: Remove ---")
    // Current: [E, D, C, B, F, E]
    p_deque.remove(&q1, "C")
    fmt.print("After removing 'C' (Expected [E, D, B, F, E]): ")
    p_deque.print_deque(&q1)

    fmt.println("\n--- Test 7: Extend & Clear ---")
    p_deque.extend(&q1, []string{"X", "Y"})
    fmt.printf("Count after extend (Expected 7): %v\n", q1.count)
    fmt.printf("Status after extend: ")
    p_deque.print_deque(&q1)
    
    p_deque.clear(&q1)
    fmt.printf("Count after clear (Expected 0): %v\n", q1.count)
    fmt.printf("Status after clear: ")
    p_deque.print_deque(&q1)
    print("")

    // ----------------------------------------------------------------------------------

    q: p_deque.Deque(int)
    p_deque.deque_init(&q, initial_capacity = 4)
    defer p_deque.delete_deque(&q)

    fmt.println("--- 1. Testing Search (count & index) ---")
    p_deque.append(&q, 10)
    p_deque.append(&q, 20)
    p_deque.append(&q, 10)
    p_deque.append(&q, 30)

    fmt.printf("Count of 10 (Expected 2): %v\n", p_deque.count(&q, 10))
    idx_0, found := p_deque.index(&q, 30)
    fmt.printf("Index of 30 (Expected 3): %v (Found: %v)\n", idx_0, found)

    fmt.println("\n--- 2. Testing Rotation ---")
    // Current: [10, 20, 10, 30]
    p_deque.rotate(&q, 1) 
    // After rotate(1): [30, 10, 20, 10]
    val_0, _ := p_deque.peek_left(&q)
    fmt.printf("Peek Left after rotate(1) (Expected 30): %v\n", val_0)

    p_deque.rotate(&q, -2)
    // After rotate(-2): [20, 10, 30, 10]
    val_0, _ = p_deque.peek_left(&q)
    fmt.printf("Peek Left after rotate(-2) (Expected 20): %v\n", val_0)

    fmt.println("\n--- 3. Testing Reverse ---")
    // Current: [20, 10, 30, 10]
    p_deque.reverse(&q)
    // Reversed: [10, 30, 10, 20]
    fmt.print("Reversed sequence: ")
    p_deque.print_deque(&q) // Helper function

    fmt.println("\n--- 4. Testing Remove ---")
    // Removing the first '30'
    removed := p_deque.remove(&q, 30)
    fmt.printf("Removed 30? (Expected true): %v\n", removed)
    fmt.print("Sequence after removal: ")
    p_deque.print_deque(&q) // Expected: [10, 10, 20]

    fmt.println("\n--- 5. Testing Extend & Clear ---")
    extra := []int{100, 200}
    p_deque.extend(&q, extra)
    fmt.printf("Count after extend (Expected 5): %v\n", q.count)
    fmt.print("Sequence is now: ")
    p_deque.print_deque(&q) 

    string_value := p_deque.to_string(&q)
    print("string_value:", string_value) // string_value: deque([10, 10, 20, 100, 200])
    
    p_deque.clear(&q)
    fmt.printf("Count after clear (Expected 0): %v\n", q.count)

    elapsed: time.Duration = time.since(start)
    print("Odin took:", elapsed)

    // this cleans up memory of `q_str` and `string_value`
    free_all(context.temp_allocator)
}

/*
$ cd 'C:\Users\mikec\Visual Studio Code' && odin run .
Hello from Odin!
--- Test 1: Basic Append and Pop ---
Pop Left (Expected A): A

--- Test 2: Growth & Unwrapping ---
Count after growth (Expected 5): 5
New Capacity (Expected 8): 8
Current State: [B, C, D, E, F]

--- Test 3: Rotation (Positive & Negative) ---
After rotate(2) (Expected [E, F, B, C, D]): [E, F, B, C, D]
After rotate(-1) (Expected [F, B, C, D, E]): [F, B, C, D, E]

--- Test 4: Reverse ---
After reverse (Expected [E, D, C, B, F]): [E, D, C, B, F]

--- Test 5: Count & Index ---
Count of 'E' (Expected 2): 2
Index of 'C' (Expected 2): 2

--- Test 6: Remove ---
After removing 'C' (Expected [E, D, B, F, E]): [E, D, B, F, E]

--- Test 7: Extend & Clear ---
Count after extend (Expected 7): 7
Status after extend: [E, D, B, F, E, X, Y]
Count after clear (Expected 0): 0
Status after clear: []

--- 1. Testing Search (count & index) ---
Count of 10 (Expected 2): 2
Index of 30 (Expected 3): 3 (Found: true)

--- 2. Testing Rotation ---
Peek Left after rotate(1) (Expected 30): 30
Peek Left after rotate(-2) (Expected 20): 20

--- 3. Testing Reverse ---
Reversed sequence: [10, 30, 10, 20]

--- 4. Testing Remove ---
Removed 30? (Expected true): true
Sequence after removal: [10, 10, 20]

--- 5. Testing Extend & Clear ---
Count after extend (Expected 5): 5
Sequence is now: [10, 10, 20, 100, 200]
string_value: deque([10, 10, 20, 100, 200])
Count after clear (Expected 0): 0
Odin took: 3.0248ms
*/