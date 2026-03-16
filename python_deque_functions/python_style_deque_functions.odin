package python_deque_functions

import "base:runtime"
import "core:slice"
import "core:fmt"
import "core:strings"

print :: fmt.println


// Convenience function that lists all functions defined in `python_style_deque_functions.odin`
show_deque_functions :: proc() {
    print("============================================================================================================")
    print("██████╗ ███████╗ ██████╗ ██╗   ██╗███████╗    ███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗")
    print("██╔══██╗██╔════╝██╔═══██╗██║   ██║██╔════╝    ██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝")
    print("██║  ██║█████╗  ██║   ██║██║   ██║█████╗      █████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗")
    print("██║  ██║██╔══╝  ██║▄▄ ██║██║   ██║██╔══╝      ██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║")
    print("██████╔╝███████╗╚██████╔╝╚██████╔╝███████╗    ██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║")
    print("╚═════╝ ╚══════╝ ╚══▀▀═╝  ╚═════╝ ╚══════╝    ╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝")
    print("============================================================================================================")
    print("---- deque functions (python-style) ----")
    print("============================================================================================================")
    print("append(q, val)                             - Adds an element to the right end; grows if capacity is reached.")
    print("clear(q)                                   - Resets indices and count, keeping capacity (zeroes memory).")
    print("copy(q)                                    - Returns a shallow copy of the deque with a new allocation.")
    print("count(q, value)                            - Returns the number of occurrences of value in the deque.")
    print("extend(q, items)                           - Appends all elements from a slice to the right end.")
    print("index(q, value)                            - Returns the logical index of the first occurrence of value.")
    print("insert(q, i, value)                        - Inserts value at logical index i, shifting elements as needed.")
    print("pop(q)                                     - Removes and returns the rightmost element (T, bool).")
    print("remove(q, value)                           - Removes the first occurrence of a value from the deque.")
    print("reverse(q)                                 - Reverses the elements of the deque in-place.")
    print("<there's no sort()>")
    print("--------------------")
    print("append_left(q, val)                        - Adds an element to the left end (head) using modulo wrapping.")
    print("extend_left(q, items)                      - Appends all elements from a slice to the left (reverses order).")
    print("pop_left(q)                                - Removes and returns the leftmost element (T, bool).")
    print("rotate(q, n)                               - Rotates deque n steps right (positive) or left (negative).")
    print("--------------------")
    print("deque_init(q, initial_cap, allocator)      - Initializes a double-ended queue using a circular buffer.")
    print("delete_deque(q)                            - Frees the memory allocated for the deque's internal data.")
    print("peek(q)                                    - Returns the rightmost element without removing it (T, bool).")
    print("peek_left(q)                               - Returns the leftmost element without removing it (T, bool).")
    print("reserve(q, n)                              - Pre-allocates memory for n elements to prevent re-allocations.")
    print("contains(q, value)                         - Checks if the given value exists within the deque.")
    print("to_string(q, allocator)                    - Returns a string representation: deque([e1, e2, ...]).")
    print("print_deque(q)                             - Prints the current logical state of the deque to stdout.")
    print("--------------------")
    print("make_deque_iterator(q)                     - Returns Deque_Iterator, Creates a state object for walking the deque logically.")
    print("deque_iterator(it)                         - Returns (T, int, bool), The 'step' function that yields values for a for-loop.")
    print("make_deque_iterator_reverse(q)             - Returns Deque_Iterator, Initializes an iterator starting at the tail.")
    print("deque_iterator_reverse(it)                 - Returns (T, int, bool), Steps backward toward the head until index < 0.")
    print("get(q, i)           -> (T, bool)           - Returns the element at logical index i (supports negative indexing).")
    print("set(q, i, val)      -> bool                - Replaces the element at logical index i with val.")
    print("length(q)           -> int                 - Returns the current number of elements (inline access).")
    print("to_slice(q, allocator) -> []T              - Returns a new linear slice of all items in logical order.")
    print("============================================================================================================")
}

Deque :: struct($T: typeid) {
    data:      []T,
    head:      int,
    tail:      int,
    count:     int,
    capacity:  int,
    allocator: runtime.Allocator,
}

// Equivalent to deque(maxlen=N)
deque_init :: proc(q: ^Deque($T), initial_capacity := 8, allocator := context.allocator) {
    q.data = make([]T, initial_capacity, allocator)
    q.capacity = initial_capacity
    q.allocator = allocator
}

// Python: q.append(item)
append :: proc(q: ^Deque($T), item: T) {
    if q.count == q.capacity {
        _grow(q)
    }
    q.data[q.tail] = item
    q.tail = (q.tail + 1) % q.capacity
    q.count += 1
}

// Python: q.appendleft(item)
append_left :: proc(q: ^Deque($T), item: T) {
    if q.count == q.capacity {
        _grow(q)
    }
    // Wrap backward
    q.head = (q.head - 1 + q.capacity) % q.capacity
    q.data[q.head] = item
    q.count += 1
}

// Python: q.pop()
pop :: proc(q: ^Deque($T)) -> (T, bool) {
    if q.count == 0 do return {}, false
    
    q.tail = (q.tail - 1 + q.capacity) % q.capacity
    val := q.data[q.tail]
    q.count -= 1
    return val, true
}

// Python: q.popleft()
pop_left :: proc(q: ^Deque($T)) -> (T, bool) {
    if q.count == 0 do return {}, false
    
    val := q.data[q.head]
    q.head = (q.head + 1) % q.capacity
    q.count -= 1
    return val, true
}

// INTERNAL: Resizes the buffer when full
_grow :: proc(q: ^Deque($T)) {
    new_cap := q.capacity * 2
    new_data := make([]T, new_cap, q.allocator)
    
    // Crucial: When growing a ring buffer, you must "unwrap" it
    // into the new array so head starts at 0 again.
    for i in 0 ..< q.count {
        new_data[i] = q.data[(q.head + i) % q.capacity]
    }
    
    delete(q.data, q.allocator)
    q.data = new_data
    q.capacity = new_cap
    q.head = 0
    q.tail = q.count
}

// Add this to your library if you haven't yet!
delete_deque :: proc(q: ^Deque($T)) {
    delete(q.data, q.allocator)
}


// Returns the first element without removing it
peek_left :: proc(q: ^Deque($T)) -> (T, bool) {
    if q.count == 0 do return {}, false
    return q.data[q.head], true
}

// Returns the last element without removing it
peek :: proc(q: ^Deque($T)) -> (T, bool) {
    if q.count == 0 do return {}, false
    // Calculate tail index (the item just before the current tail pointer)
    tail_idx := (q.tail - 1 + q.capacity) % q.capacity
    return q.data[tail_idx], true
}

// Python: q.clear()
// Resets the indices but keeps the allocated memory
clear :: proc(q: ^Deque($T)) {
    q.head = 0
    q.tail = 0
    q.count = 0
    slice.zero(q.data) // clears the old data for safety
}

// Python: q.extend(other_slice)
extend :: proc(q: ^Deque($T), items: []T) {
    for item in items {
        append(q, item)
    }
}

// Python: q.extendleft(other_slice)
// Note: Python's extendleft reverses the order of the input!
extend_left :: proc(q: ^Deque($T), items: []T) {
    for item in items {
        append_left(q, item)
    }
}

// Python: q.count(value)
count :: proc(q: ^Deque($T), value: T) -> int {
    found := 0
    for i in 0 ..< q.count {
        if q.data[(q.head + i) % q.capacity] == value {
            found += 1
        }
    }
    return found
}

// Python: q.index(value)
index :: proc(q: ^Deque($T), value: T) -> (int, bool) {
    for i in 0 ..< q.count {
        if q.data[(q.head + i) % q.capacity] == value {
            return i, true
        }
    }
    return -1, false
}

// Python: q.rotate(n)
rotate :: proc(q: ^Deque($T), n: int) {
    if q.count <= 1 do return
    
    // Normalize n to be within the count
    steps := n % q.count
    if steps == 0 do return

    if steps > 0 {
        // Rotate right: pop from right, append to left
        for _ in 0 ..< steps {
            val, _ := pop(q)
            append_left(q, val)
        }
    } else {
        // Rotate left: pop from left, append to right
        for _ in 0 ..< abs(steps) {
            val, _ := pop_left(q)
            append(q, val)
        }
    }
}

// Python: q.reverse()
reverse :: proc(q: ^Deque($T)) {
    if q.count <= 1 do return
    
    // We swap elements from the logical start and logical end
    for i in 0 ..< q.count / 2 {
        idx_a := (q.head + i) % q.capacity
        idx_b := (q.head + q.count - 1 - i) % q.capacity
        q.data[idx_a], q.data[idx_b] = q.data[idx_b], q.data[idx_a]
    }
}

// Python: q.remove(value) - removes the first occurrence
remove :: proc(q: ^Deque($T), value: T) -> bool {
    idx, found := index(q, value)
    if !found do return false

    // Shift everything after the found index one spot to the left
    for i in idx ..< q.count - 1 {
        curr := (q.head + i) % q.capacity
        next := (q.head + i + 1) % q.capacity
        q.data[curr] = q.data[next]
    }
    
    // Update the tail and count
    q.tail = (q.tail - 1 + q.capacity) % q.capacity
    q.count -= 1
    return true
}

// Helper function to see the logical order without draining the queue
print_deque :: proc(q: ^Deque($T)) {
    fmt.print("[")
    for i in 0 ..< q.count {
        idx := (q.head + i) % q.capacity
        fmt.printf("%v", q.data[idx])
        if i < q.count - 1 do fmt.print(", ")
    }
    fmt.println("]")
}

to_string :: proc(q: ^Deque($T), allocator := context.temp_allocator) -> string {
    sb := strings.builder_make(allocator)
    strings.write_string(&sb, "deque([")
    
    for i in 0 ..< q.count {
        idx := (q.head + i) % q.capacity
        fmt.sbprintf(&sb, "%v", q.data[idx])
        if i < q.count - 1 {
            strings.write_string(&sb, ", ")
        }
    }
    
    strings.write_string(&sb, "])")
    return strings.to_string(sb)
}

// Python: value in q
// Odin: contains(&q, value)
contains :: proc(q: ^Deque($T), value: T) -> bool {
    for i in 0 ..< q.count {
        if q.data[(q.head + i) % q.capacity] == value {
            return true
        }
    }
    return false
}

// Python: q.copy()
// Creates a shallow copy of the deque with a new allocation
copy :: proc(q: ^Deque($T), allocator := context.allocator) -> Deque(T) {
    new_q: Deque(T)
    // We initialize with the current count to be efficient
    deque_init(&new_q, max(8, q.count), allocator)
    
    // Copy elements in logical order
    for i in 0 ..< q.count {
        append(&new_q, q.data[(q.head + i) % q.capacity])
    }
    
    return new_q
}

// Python: q.insert(idx, value)
// Inserts value at logical index idx
insert :: proc(q: ^Deque($T), idx: int, value: T) -> bool {
    // Python's insert handles out-of-bounds by clamping
    insert_idx := clamp(idx, 0, q.count)

    if q.count == q.capacity {
        _grow(q)
    }

    // Shift everything from insert_idx to the right by one
    // We go backwards to avoid overwriting data
    for i := q.count; i > insert_idx; i -= 1 {
        curr := (q.head + i) % q.capacity
        prev := (q.head + i - 1) % q.capacity
        q.data[curr] = q.data[prev]
    }

    // Place the new value
    q.data[(q.head + insert_idx) % q.capacity] = value
    
    // Update state
    q.tail = (q.tail + 1) % q.capacity
    q.count += 1
    
    return true
}

reserve :: proc(q: ^Deque($T), new_capacity: int) {
    if new_capacity <= q.capacity do return
    
    new_data := make([]T, new_capacity, q.allocator)
    for i in 0 ..< q.count {
        new_data[i] = q.data[(q.head + i) % q.capacity]
    }
    
    delete(q.data, q.allocator)
    q.data = new_data
    q.capacity = new_capacity
    q.head = 0
    q.tail = q.count
}

// ----------------------------------------------------------------------------------------------------------------

Deque_Iterator :: struct($T: typeid) {
    deque: ^Deque(T),
    index: int, // How many items we have yielded so far (0 to deque.count)
}

// Helper to create it
make_deque_iterator :: proc(q: ^Deque($T)) -> Deque_Iterator(T) {
    return Deque_Iterator(T){
        deque = q,
        index = 0,
    }
}


deque_iterator :: proc(it: ^Deque_Iterator($T)) -> (T, int, bool) {
    // If we've visited all items, stop
    if it.index >= it.deque.count {
        return {}, -1, false
    }

    // Calculate the logical position based on the deque's head
    logical_idx := (it.deque.head + it.index) % it.deque.capacity
    val := it.deque.data[logical_idx]
    
    // Save the current index for the user, then increment
    current_idx := it.index
    it.index += 1

    return val, current_idx, true
}


make_deque_iterator_reverse :: proc(q: ^Deque($T)) -> Deque_Iterator(T) {
    return Deque_Iterator(T){
        deque = q,
        index = q.count - 1, // Start at the last logical item
    }
}


deque_iterator_reverse :: proc(it: ^Deque_Iterator($T)) -> (T, int, bool) {
    // We start 'it.index' at 'q.count - 1' when we create the iterator
    if it.index < 0 {
        return {}, -1, false
    }

    // Logical index math: Start at head and move forward by 'it.index'
    // Even though we are walking 'it.index' backward, the formula stays the same!
    logical_idx := (it.deque.head + it.index) % it.deque.capacity
    val := it.deque.data[logical_idx]
    
    current_idx := it.index
    it.index -= 1 // Move toward the start

    return val, current_idx, true
}

// ----------------------------------------------------------------------------------------------------------------

/*
    ---- EXAMPLE: ----
    q: p_deque.Deque(int)
    p_deque.deque_init(&q)
    defer p_deque.delete_deque(&q)

    p_deque.append(&q, 10)
    p_deque.append(&q, 20)
    p_deque.append(&q, 30)

    // Manual loop using the iterator
    it := p_deque.make_deque_iterator(&q)
    
    // In Odin, this is a very common way to use custom iterators:
    for val, i in p_deque.deque_iterator(&it) {
        fmt.printf("Item at logical index %d is %v\n", i, val)
    }

    // Current state: [10, 20, 30]
    it_rev := p_deque.make_deque_iterator_reverse(&q)

    fmt.println("Walking backward:")
    for val, i in p_deque.deque_iterator_reverse(&it_rev) {
        fmt.printf("Index %d: %v\n", i, val)
    }

    
    ---- OUTPUT: ----
    Item at logical index 0 is 10
    Item at logical index 1 is 20
    Item at logical index 2 is 30
    Walking backward:
    Index 2: 30
    Index 1: 20
    Index 0: 10
    
*/

// ----------------------------------------------------------------------------------------------------------------

// Python: dq[i]
get :: proc(q: ^Deque($T), index: int) -> (T, bool) {
    if q.count == 0 do return {}, false

    // Handle negative indexing like Python (e.g., -1 is the last item)
    idx := index
    if idx < 0 {
        idx = q.count + idx
    }

    // Bounds check
    if idx < 0 || idx >= q.count {
        return {}, false
    }

    // Map logical index to physical ring buffer index
    physical_idx := (q.head + idx) % q.capacity
    return q.data[physical_idx], true
}


// Python: dq[i] = val
set :: proc(q: ^Deque($T), index: int, val: T) -> bool {
    idx := index
    if idx < 0 do idx = q.count + idx

    if idx < 0 || idx >= q.count do return false

    physical_idx := (q.head + idx) % q.capacity
    q.data[physical_idx] = val
    return true
}

// Python: len(q)
length :: #force_inline proc(q: ^Deque($T)) -> int {
    return q.count
}

// Returns a linear slice containing all elements in logical order
to_slice :: proc(q: ^Deque($T), allocator := context.allocator) -> []T {
    if q.count == 0 do return nil
    
    // Allocate exactly enough space for the current items
    output := make([]T, q.count, allocator)
    
    for i in 0 ..< q.count {
        logical_idx := (q.head + i) % q.capacity
        output[i] = q.data[logical_idx]
    }
    
    return output
}
