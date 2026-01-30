package python_deque_functions

import "base:runtime"
// import "core:mem"
import "core:slice"
import "core:fmt"
import "core:strings"

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