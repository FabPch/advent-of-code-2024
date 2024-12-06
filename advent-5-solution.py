import pprint

file_path = r'advent-5-input.txt'
rules = {}
pages_in_order = []
result = 0
result_reordered = 0

with open(file_path, encoding='utf-8') as file:
    lines = file.readlines()

def create_rule_list(rules):
    first = list()
    last = list()

    while len(rules) > 0:
        for key, value in rules.items():

            first_item = None
            last_item = None
            
            if len(value["before"]) == 0:
                first.append(key)
                first_item = int(key)
            if len(value["after"]) == 0:
                last_item = int(key)
                last.insert(0, key)
    
        if first_item is None and last_item is None:
            print("first_item and last_item are None")
            continue

        print(f"first_item is: {first_item}")
        print(f"last_item is: {last_item}")
        if first_item == last_item and first_item is not None:
            last.insert(0, first_item)
            return first + last
        
        if first_item is not None:
            rules.pop(str(first_item))
        if last_item is not None:
            rules.pop(str(last_item))
        
        for key, value in rules.items():
            if first_item in value["before"]:
                rules[key]["before"].remove(first_item)
            if last_item in value["before"]:
                rules[key]["before"].remove(last_item)
            if first_item in value["after"]:
                rules[key]["after"].remove(first_item)
            if last_item in value["after"]:
                rules[key]["after"].remove(last_item)
        print('rules is now:')
        # pprint.pp(rules)
    
        print(f"first is: {first}")
        print(f"last is: {last}")
    return first + last

def reordering_new(pages, rules):
    ''
def reordering(pages, rules):
    cpt = 0

    print(f"nb to inspect: {pages[0]}")
    before = rules[str(pages[0])]["before"]
    after = rules[str(pages[0])]["after"]
    print(f"pages is now: {pages}")
    print(before)
    print(after)

    nb_to_inspect = int(pages[0])
    first = list(pages[0:0])
    last = list(pages[1:len(pages)])
    
    while (any(int(page) in after for page in first) or any(int(page) in before for page in last) or len(pages) > len(first)) and cpt < 100:
        print(f"nb to inspect: {nb_to_inspect}")
        print(f"first: {first}")
        print(f"last: {last}")
        
        before = rules[str(nb_to_inspect)]["before"]
        after = rules[str(nb_to_inspect)]["after"]

        # si 97 est dans after de 13, KO, on remplace 13 par 97, et on reinit before et after
        has_swap = False
        for j in range(0, len(first)):
            for a in after:
                if first[j] == a:
                    swap = first[j]
                    first[j] = nb_to_inspect
                    nb_to_inspect = swap
                    has_swap = True
                    break
            if has_swap:
                break

        if has_swap:
            cpt += 1
            continue
        # si 97 est dans before de 13, KO, on remplace 13 par 97, et on reinit before et after
        # if any(int(page) in before for page in pages[i+1:page_length]):
        for j in range(0, len(last)):
            for b in before:
                if last[j] == b:
                    swap = last[j]
                    last[j] = nb_to_inspect
                    nb_to_inspect = swap
                    has_swap = True
                    break
            if has_swap:
                break
        
        if has_swap:
            cpt += 1
            continue

        first.append(nb_to_inspect)
        if len(last) > 0:
            nb_to_inspect = last.pop(0)

        cpt += 1
        
    print(f"cpt is now: {cpt}")
    return int(first[int((len(first)-1)/2)])
    
line_number = 0
for line in lines:
    # verify if the line is a rule line
    if '|' in line:
        order = line.strip().split('|')

        if rules.get(order[0]) is None:
            rules[order[0]] = {"before": set(), "after": set([int(order[1])])}
        else:
            rules[order[0]]["after"].add(int(order[1]))

        if rules.get(order[1]) is None:
            rules[order[1]] = {"before": set([int(order[0])]), "after": set()}
        else:
            rules[order[1]]["before"].add(int(order[0]))
    # verify if the list respect the rules
    elif ',' in line:
        pages = list(map(int, line.strip().split(',')))
        page_length = len(pages)
        in_order = True
        
        for i in range(0, page_length):
            if rules.get(pages[i]) is None:
                print(f"no rules for number: {pages[i]} in line: {line_number}")
                in_order = False
                break
            
            before = rules[pages[i]]["before"]
            after = rules[pages[i]]["after"]
            if any(int(page) in after for page in pages[0:i]) or any(int(page) in before for page in pages[i+1:page_length]):
                print(f"Line {line_number} is not in order")
                # result_reordered += reordering(pages, rules)
                in_order = False
                break

        print(f"line_number {line_number}")
        if in_order:
            print(f"middle is {(page_length-1)/2}")
            print(f"value is {int(pages[int((page_length-1)/2)])}")
            result += int(pages[int((page_length-1)/2)])

        line_number += 1

pprint.pp(rules)

ordered_list = create_rule_list(rules)

# print(f"ordered list is: {ordered_list}")

print(f"answer 1 is: {result}")
print(f"answer 2 is: {result_reordered}")
# 6075 is too high

# input = ('1', '2', '75', '8', '8')
# before = (97, 75, 47, 61, 53, 29)
# if any(int(p) in before for p in input):
#     print("hey")
# 97,13,75,29,47

# 97
# [] et [13,75,29,47] => OK

# 13
# [97] et [75, 29, 47] => 13 doit être après 75



# init = ()
# nb_to_inspect = 13
# before = ()
# after = ()
# if nb_to_inspect in before:
#     init
# if any(int(page) in after for page in pages[0:i]) or any(int(page) in before for page in pages[i+1:page_length]):

# 75
# [97] et [13, 29, 47] => OK

# 13
# [97, 75] et [29, 47] => 29 doit être avant 13

# 29
# [97, 75] et [13, 47] => 47 doit être avant 29

# 47
# [97, 75] et [29, 13] => OK

# 29
# [97, 75, 47] et [13] => OK

# [97, 75, 47, 29, 13] => OK


# {'47': {'before': {97, 75}, 'after': {29, 13, 61, 53}},
#  '53': {'before': {97, 75, 61, 47}, 'after': {13, 29}},
#  '97': {'before': set(), 'after': {75, 13, 47, 61, 53, 29}},
#  '13': {'before': {97, 75, 47, 61, 53, 29}, 'after': set()},
#  '61': {'before': {97, 75, 47}, 'after': {29, 53, 13}},
#  '75': {'before': {97}, 'after': {13, 47, 29, 53, 61}},
#  '29': {'before': {97, 75, 47, 53, 61}, 'after': {13}}}
