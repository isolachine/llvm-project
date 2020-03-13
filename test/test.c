int g;
int g_incr(int c) {
  g += c;
  return g;
}
int loop(int a, int b, int c) {
  int i;
  int ret = 0;
  for (i = a; i < b; i++) {
    g_incr(c);
  }
  return ret + g;
}

// int g;
// int erk(int a, int b) {
//   int i;
//   int x = g;
//   int ret = 1;
//   for (i = 0; i < b; i++) {
//     ret = ret * a;
//   }
//   return ret + x;
// }