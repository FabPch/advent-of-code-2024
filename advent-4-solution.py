cpt = 0
with open('advent-4-input.txt', 'r') as file:
    lines = file.readlines()
    length = len(lines[0].strip())
    for i in range(0, len(lines)-2):
        for j in range(0, length-2):
            text_1 = lines[i].strip()[j] + lines[i+1].strip()[j+1] + lines[i+2].strip()[j+2]
            text_2 = lines[i+2].strip()[j] + lines[i+1].strip()[j+1] + lines[i].strip()[j+2]
            if text_1 in ('MAS', 'SAM') and text_2 in ('MAS', 'SAM'):
                cpt += 1
print(f'answer 2 is : {cpt}')
