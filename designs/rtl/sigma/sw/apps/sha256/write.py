for t in range(16,64):
    print(f"W[{t}] = W[{t-16}] + W[{t-7}] + custom0_instr_wrapper(W[{t-15}],W[{t-2}]);")