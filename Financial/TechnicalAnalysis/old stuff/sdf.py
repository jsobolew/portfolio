
def smallestNegativeBalance(debts):
    balances = Counter()
    for d in debts:
        balances[d[0]] += int(d[2])
        balances[d[1]] -= int(d[2])
    string = balances.most_common(1)[0][0]
    isNegative = False
    for b in balances:
        if balances[b] < 0:
            isNegative = True
            break 
    print(balances)
    if isNegative:
        return string
    else:
        return "Nobody has a negative balance"