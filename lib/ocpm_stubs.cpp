#include "ocpm_stubs.h"

extern "C" CAMLprim value ml_create(value u) {
    CPM cpm = new CPM(10, 1.0, 0.0, 1.0, 42);
    return (value)cpm;
}
