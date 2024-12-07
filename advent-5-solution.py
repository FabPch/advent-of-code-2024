import copy

file_path = r'advent-5-input.txt'
rules = {}
pages_in_order = []
result = 0
result_reordered = 0

with open(file_path, encoding='utf-8') as file:
    lines = file.readlines()

def create_line_rules(rules, pages):
    invalid_keys = set()
    for key in rules:
        if key not in pages:
            invalid_keys.add(key)
            for nested_key, nested_value in rules.items():
                if int(key) in nested_value["before"]:
                    rules[nested_key]["before"].remove(int(key))
                if int(key) in nested_value["after"]:
                    rules[nested_key]["after"].remove(int(key))
    
    for i in invalid_keys:
        rules.pop(i)
    return rules

def create_rule_list(rules):
    first = list()
    last = list()

    while len(rules) > 0:
        first_item = None
        last_item = None
        
        for key, value in rules.items():
            if len(value["before"]) == 0:
                first.append(key)
                first_item = int(key)
            if len(value["after"]) == 0:
                last_item = int(key)
                last.insert(0, key)
    
        if first_item is None and last_item is None:
            print("first_item and last_item are None")
            exit()

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
    return first + last

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
        # pages = list(map(int, line.strip().split(',')))
        pages = line.strip().split(',')
        page_length = len(pages)
        in_order = True
        
        for i in range(0, page_length):
            if rules.get(pages[i]) is None:
                # print(f"no rules for number: {pages[i]} in line: {line_number}")
                in_order = False
                break
            
            before = rules[pages[i]]["before"]
            after = rules[pages[i]]["after"]
            if any(int(page) in after for page in pages[0:i]) or any(int(page) in before for page in pages[i+1:page_length]):
                print(f"Line {line_number} is not in order")
                
                line_rules = create_line_rules(copy.deepcopy(rules), pages.copy())
                line_rule_list = create_rule_list(copy.deepcopy(line_rules))
                result_reordered += int(line_rule_list[int((len(line_rule_list)-1)/2)])
                
                in_order = False
                break

        if in_order:
            print(f"middle is {(page_length-1)/2}")
            print(f"value is {int(pages[int((page_length-1)/2)])}")
            result += int(pages[int((page_length-1)/2)])

        line_number += 1

print(f"answer 1 is: {result}")

print(f"answer 2 is: {result_reordered}")
