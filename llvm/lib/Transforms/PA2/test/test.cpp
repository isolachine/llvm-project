#include <atomic>

std::atomic<uint64_t> sharedValue(0);

void storeValue(uint64_t a) { sharedValue.store(a, std::memory_order_relaxed); }

uint64_t loadValue() { return sharedValue.load(std::memory_order_relaxed); }

int main(int argc, char **argv) {
  int i, j, k, t = 0;
  for (i = 0; i < 10; i++) {
    for (j = 0; j < 10; j++) {
      for (k = 0; k < 10; k++) {
        t++;
        uint64_t aa = sharedValue.load(std::memory_order_relaxed);
        aa += 55;
        storeValue(aa);
      }
    }
  }
  return t;
}

int anotherFunction(int argc, char **argv) {
  int i, j, k, t = 0;
  for (i = 0; i < 10; i++) {
    for (j = 0; j < 10; j++) {
      for (k = 0; k < 10; k++) {
        t++;
      }
    }
    for (j = 0; j < 10; j++) {
      t++;
    }
  }
  for (i = 0; i < 20; i++) {
    for (j = 0; j < 20; j++) {
      t++;
    }
    for (j = 0; j < 20; j++) {
      t++;
    }
  }
  return t;
}