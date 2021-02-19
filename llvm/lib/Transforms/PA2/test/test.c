int foo() {
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

int bar() {
  int i, j, k, t = 0;
  for (i = 0; i < 20; i++) {
    for (j = 0; j < 20; j++) {
      t++;
    }
    for (j = 0; j < 10; j++) {
      for (k = 0; k < 10; k++) {
        t++;
      }
    }
  }
  return t;
}

int main(int argc, char const *argv[]) {
  if (argc) {
    char const *arg = argv[0];
    int index = 0;
    while (*(arg + index) != '\0') {
      foo();
      bar();
      index++;
    }
  }
  return 0;
}
