#(py_var (musicxml_file)

musicxml_file = "C:\\Users\\charl\\OneDrive_usp.br\\Documents\\OpenMusic\\in-files\\untitled.musicxml"
# ======================= Add Variables Just above this Line ========================

import music21 
from om_py import lispify
from om_py import to_om

# =====================================================================================

def add_dots(music_value, musical_dots, inicial_value): # function to add dots to a note
    if musical_dots == 0:
        return round(music_value)
    else:
        new_number = (int(inicial_value) / 2) 
        new_music_value = int(new_number) + music_value
        new_musical_dots = musical_dots - 1
        return add_dots(new_music_value, new_musical_dots, new_number)


# =====================================================================================
def names2ratio (names):
    #print(names)
    if names == "breve":
        return 2/1
    elif names == "whole":
        return 1
    elif names == "half":
        return 2
    elif names == "quarter":
        return 4
    elif names == "eighth":
        return 8
    elif names == "16th":
        return 16
    elif names == "32nd":
        return 32
    elif names == "64th":
        return 64
    elif names == "128th":
        return 128
    elif names == "256th":
        return 256
    elif names == "512th":
        return 512
    elif names == "1024th":
        return 1024
    else:
        return -1

# =====================================================================================

def check_the_var (list_string, string_code):
    list = []
    for string in list_string:
        last_char = -abs(len(string_code))
        last_chars = string[last_char:]
        just_number = string.split(last_chars)[0]
        if last_chars == string_code:
            list.append(just_number)
    return list

# =====================================================================================

def remove_the_var (list_string, string_code):
    list = []
    for string in list_string:
        last_char = -abs(len(string_code))
        last_chars = string[last_char:]
        just_number = string.split(last_chars)[0]
        if last_chars != string_code:
            list.append(string)
    return list

# =====================================================================================
class ckn_notes:
    
    midicent = {'C-1': 2300, 'C-2': 3500, 'C-3': 4700, 'C-4': 5900, 'C-5': 7100, 'C-6': 8300, 'C-7': 9500, 'C`1': 2350, 'C`2': 3550, 'C`3': 4750, 'C`4': 5950, 'C`5': 7150, 'C`6': 8350, 'C`7': 9550, 'C1': 2400, 'C2': 3600, 'C3': 4800, 'C4': 6000, 'C5': 7200, 'C6': 8400, 'C7': 9600, 'C~1': 2450, 'C~2': 3650, 'C~3': 4850, 'C~4': 6050, 'C~5': 7250, 'C~6': 8450, 'C~7': 9650, 'C#1': 2500, 'C#2': 3700, 'C#3': 4900, 'C#4': 6100, 'C#5': 7300, 'C#6': 8500, 'C#7': 9700, 'D-1': 2500, 'D-2': 3700, 'D-3': 4900, 'D-4': 6100, 'D-5': 7300, 'D-6': 8500, 'D-7': 9700, 'D`1': 2550, 'D`2': 3750, 'D`3': 4950, 'D`4': 6150, 'D`5': 7350, 'D`6': 8550, 'D`7': 9750, 'D1': 2600, 'D2': 3800, 'D3': 5000, 'D4': 6200, 'D5': 7400, 'D6': 8600, 'D7': 9800, 'D~1': 2650, 'D~2': 3850, 'D~3': 5500, 'D~4': 6500, 'D~5': 7550, 'D~6': 8650, 'D~7': 9750, 'D#1': 2700, 'D#2': 3900, 'D#3': 5100, 'D#4': 6300, 'D#5': 7500, 'D#6': 8700, 'D#7': 9900, 'E-1': 2700, 'E-2': 3900, 'E-3': 5100, 'E-4': 6300, 'E-5': 7500, 'E-6': 8700, 'E-7': 9900, 'E`1': 2750, 'E`2': 3950, 'E`3': 5150, 'E`4': 6350, 'E`5': 7550, 'E`6': 8750, 'E`7': 9950, 'E1': 2800, 'E2': 4000, 'E3': 5200, 'E4': 6400, 'E5': 7600, 'E6': 8800, 'E7': 10000, 'E~1': 2850, 'E~2': 4050, 'E~3': 5500, 'E~4': 6550, 'E~5': 7650, 'E~6': 8750, 'E~7': 9950, 'E#1': 2900, 'E#2': 4100, 'E#3': 5200, 'E#4': 6400, 'E#5': 7600, 'E#6': 8800, 'E#7': 10000, 'F-1': 2800, 'F-2': 4000, 'F-3': 5200,  'F-4': 6400, 'F-5': 7600, 'F-6': 8800, 'F-7': 10000, 'F`1': 2850, 'F`2': 4050, 'F`3': 5500, 'F`4': 6550, 'F`5': 7650, 'F`6': 8750, 'F`7': 9950, 'F1': 2900, 'F2': 4100, 'F3': 5200, 'F4': 6400, 'F5': 7600, 'F6': 8800, 'F7': 10000, 'F~1': 2950, 'F~2': 4150, 'F~3': 5500, 'F~4': 6550, 'F~5': 7650, 'F~6': 8750, 'F~7': 9950, 'F#1': 3000, 'F#2': 4200, 'F#3': 5300, 'F#4': 6500, 'F#5': 7700, 'F#6': 8900, 'F#7': 10100, 'G-1': 3000, 'G-2': 4200, 'G-3': 5300, 'G-4': 6500, 'G-5': 7700, 'G-6': 8900, 'G-7': 10100, 'G`1': 3050, 'G`2': 4250, 'G`3': 5550, 'G`4': 6550, 'G`5': 7750, 'G`6': 8950, 'G`7': 10150, 'G1': 3100, 'G2': 4300, 'G3': 5400, 'G4': 6600, 'G5': 7800, 'G6': 9000, 'G7': 10200, 'G~1': 3150, 'G~2': 4350, 'G~3': 5550, 'G~4': 6550, 'G~5': 7750, 'G~6': 8950, 'G~7': 10150, 'G#1': 3200, 'G#2': 4400, 'G#3': 5500, 'G#4': 6600, 'G#5': 7800, 'G#6': 9000, 'G#7': 10200, 'A-1': 3200, 'A-2': 4400, 'A-3': 5600, 'A-4': 6800, 'A-5': 8000, 'A-6': 9200, 'A-7': 10400, 'A`1': 3250, 'A`2': 4450, 'A`3': 5650, 'A`4': 6850, 'A`5': 8050, 'A`6': 9250, 'A`7': 10450, 'A1': 3300, 'A2': 4500, 'A3': 5700, 'A4': 6900, 'A5': 8100, 'A6': 9300, 'A7': 10500, 'A~1': 3350, 'A~2': 4550, 'A~3': 5750, 'A~4': 6950, 'A~5': 8150, 'A~6': 9350, 'A~7': 10550, 'A#1': 3400, 'A#2': 4600, 'A#3': 5800, 'A#4': 7000, 'A#5': 8200, 'A#6': 9400, 'A#7': 10600, 'B-1': 3400, 'B-2': 4600, 'B-3': 5800, 'B-4': 7000, 'B-5': 8200, 'B-6': 9400, 'B-7': 10600, 'B`1': 3450, 'B`2': 4650, 'B`3': 5850, 'B`4': 7050, 'B`5': 8250, 'B`6': 9450, 'B`7': 10650, 'B1': 3500, 'B2': 4700, 'B3': 5900, 'B4': 7100, 'B5': 8300, 'B6': 9500, 'B7': 10700, 'B~1': 3550, 'B~2': 4750, 'B~3': 5950, 'B~4': 7150, 'B~5': 8350, 'B~6': 9550, 'B~7': 10750, 'B#1': 3600, 'B#2': 4800, 'B#3': 6000, 'B#4': 7200, 'B#5': 8400, 'B#6': 9600, 'B#7': 10800}
    cents = {'C-1': '0c', 'C-2': '0c', 'C-3': '0c', 'C-4': '0c', 'C-5': '0c', 'C-6': '0c', 'C-7': '0c', 'C`1': '0c', 'C`2': '0c', 'C`3': '0c', 'C`4': '0c', 'C`5': '0c', 'C`6': '0c', 'C`7': '0c', 'C1': '0c', 'C2': '0c', 'C3': '0c', 'C4': '0c', 'C5': '0c', 'C6': '0c', 'C7': '0c', 'C~1': '0c', 'C~2': '0c', 'C~3': '0c', 'C~4': '0c', 'C~5': '0c', 'C~6': '0c', 'C~7': '0c', 'C#1': '0c', 'C#2': '0c', 'C#3': '0c', 'C#4': '0c', 'C#5': '0c', 'C#6': '0c', 'C#7': '0c', 'D-1': '0c', 'D-2': '0c', 'D-3': '0c', 'D-4': '0c', 'D-5': '0c', 'D-6': '0c', 'D-7': '0c', 'D`1': '0c', 'D`2': '0c', 'D`3': '0c', 'D`4': '0c', 'D`5': '0c', 'D`6': '0c', 'D`7': '0c', 'D1': '0c', 'D2': '0c', 'D3': '0c', 'D4': '0c', 'D5': '0c', 'D6': '0c', 'D7': '0c', 'D~1': '0c', 'D~2': '0c', 'D~3': '0c', 'D~4': '0c', 'D~5': '0c', 'D~6': '0c', 'D~7': '0c', 'D#1': '0c', 'D#2': '0c', 'D#3': '0c', 'D#4': '0c', 'D#5': '0c', 'D#6': '0c', 'D#7': '0c', 'E-1': '0c', 'E-2': '0c', 'E-3': '0c', 'E-4': '0c', 'E-5': '0c', 'E-6': '0c', 'E-7': '0c', 'E`1': '0c', 'E`2': '0c', 'E`3': '0c', 'E`4': '0c', 'E`5': '0c', 'E`6': '0c', 'E`7': '0c', 'E1': '0c', 'E2': '0c', 'E3': '0c', 'E4': '0c', 'E5': '0c', 'E6': '0c', 'E7': '0c', 'E~1': '0c', 'E~2': '0c', 'E~3': '0c', 'E~4': '0c', 'E~5': '0c', 'E~6': '0c', 'E~7': '0c', 'F-1': '0c', 'F-2': '0c', 'F-3': '0c', 'F-4': '0c', 'F-5': '0c', 'F-6': '0c', 'F-7': '0c', 'F`1': '0c', 'F`2': '0c', 'F`3': '0c', 'F`4': '0c', 'F`5': '0c', 'F`6': '0c', 'F`7': '0c', 'F1': '0c', 'F2': '0c', 'F3': '0c', 'F4': '0c', 'F5': '0c', 'F6': '0c', 'F7': '0c', 'F~1': '0c', 'F~2': '0c', 'F~3': '0c', 'F~4': '0c', 'F~5': '0c', 'F~6': '0c', 'F~7': '0c', 'F#1': '0c', 'F#2': '0c', 'F#3': '0c', 'F#4': '0c', 'F#5': '0c', 'F#6': '0c', 'F#7': '0c', 'G-1': '0c', 'G-2': '0c', 'G-3': '0c', 'G-4': '0c', 'G-5': '0c', 'G-6': '0c', 'G-7': '0c', 'G`1': '0c', 'G`2': '0c', 'G`3': '0c', 'G`4': '0c', 'G`5': '0c', 'G`6': '0c', 'G`7': '0c', 'G1': '0c', 'G2': '0c', 'G3': '0c', 'G4': '0c', 'G5': '0c', 'G6': '0c', 'G7': '0c', 'G~1': '0c', 'G~2': '0c', 'G~3': '0c', 'G~4': '0c', 'G~5': '0c', 'G~6': '0c', 'G~7': '0c', 'G#1': '0c', 'G#2': '0c', 'G#3': '0c', 'G#4': '0c', 'G#5': '0c', 'G#6': '0c', 'G#7': '0c', 'A-1': '0c', 'A-2': '0c', 'A-3': '0c', 'A-4': '0c', 'A-5': '0c', 'A-6': '0c', 'A-7': '0c', 'A`1': '0c', 'A`2': '0c', 'A`3': '0c', 'A`4': '0c', 'A`5': '0c', 'A`6': '0c', 'A`7': '0c', 'A1': '0c', 'A2': '0c', 'A3': '0c', 'A4': '0c', 'A5': '0c', 'A6': '0c', 'A7': '0c', 'A~1': '0c', 'A~2': '0c', 'A~3': '0c', 'A~4': '0c', 'A~5': '0c', 'A~6': '0c', 'A~7': '0c', 'A#1': '0c', 'A#2': '0c', 'A#3': '0c', 'A#4': '0c', 'A#5': '0c', 'A#6': '0c', 'A#7': '0c', 'B-1': '0c', 'B-2': '0c', 'B-3': '0c', 'B-4': '0c', 'B-5': '0c', 'B-6': '0c', 'B-7': '0c', 'B`1': '0c', 'B`2': '0c', 'B`3': '0c', 'B`4': '0c', 'B`5': '0c', 'B`6': '0c', 'B`7': '0c', 'B1': '0c', 'B2': '0c', 'B3': '0c', 'B4': '0c', 'B5': '0c', 'B6': '0c', 'B7': '0c', 'B~1': '0c', 'B~2': '0c', 'B~3': '0c', 'B~4': '0c', 'B~5': '0c', 'B~6': '0c', 'B~7': '0c', 'B#1': '0c', 'B#2': '0c', 'B#3': '0c', 'B#4': '0c', 'B#5': '0c', 'B#6': '0c', 'B#7': '0c'}

class om_group:
    total_duration = 0
    total_pulses = []
    minum_value = None
    dots = 0
    active = False

class om_note:
    total_duration = 0
    rest = False
    total_pulses = 0
    minum_value = None
    dots = 0
    active = False
    tie = False

class om_measure:
    tree = []
    time_signature = 154/12
    #total_pulses = []
    #active = False

class om_voice:
    tree = []
    time_signature = 154/12
    #total_pulses = []
    #active = False

class om_part:
    tree = []


PULSE_BY_MEASURE = []
PULSE = []
PULSE_TO_KNOW_WHEN_FINISH = []
PART = []

# Global Variables

PITCHES = []

PITCHES_BY_VOICES = []
VAR = []
dynamic_value = []
tuplets_duration = []
final_tuplet = []

microton_of_note_values = ckn_notes() 

    
xml_data = music21.converter.parse(musicxml_file)
py2om_om_part = om_part()
py2om_voice = om_voice()

for part_index in xml_data.parts:
    
    instrument = part_index.getInstrument().instrumentName
    #print(instrument)
    #print('\n')
    all_measures = part_index.getElementsByClass(music21.stream.Measure)
    #number_part_index = 1
    for measure in all_measures:
        try:
            TimeSignature = list(map(lambda x: int(x), measure.timeSignature.ratioString.split('/')))
        except:
            TimeSignature = TimeSignature 
        PULSE = []
        PULSE_TO_KNOW_WHEN_FINISH = []
    
        
        
        for notes_and_rests in measure.notesAndRests: ### Todos os valores ritmicos (eu acho)
            
           
            # ============================================================================
            # ============================================================================
            if isinstance(notes_and_rests, music21.note.Rest):
                isRest = True
            else:
                isRest = False
            
            if notes_and_rests.tie:
                tie = notes_and_rests.tie.type
            else:
                tie = None
            duration = notes_and_rests.duration


            
            # ============================================================================
            # ============================================================================

            
            
            
            if len(duration.tuplets) > 0: # Se tiver tuplets
                tuplets = duration.tuplets
                ratio = duration.aggregateTupletMultiplier() 
                how_many_dots_have_dots = duration.dots
                valor_da_nota = duration.type
                durationActual = tuplets[0].durationActual.type
                om_tree_valor = names2ratio(durationActual) / names2ratio(valor_da_nota) # durationActual
                tuplets_duration = round((names2ratio(valor_da_nota) / ratio.numerator) * (TimeSignature[1] / 4))
                tuplets_pulse = names2ratio(durationActual) / names2ratio(valor_da_nota)
                start_tuplets_pulse = tuplets_pulse
                tuplets_pulse_dot = add_dots(om_tree_valor, how_many_dots_have_dots, om_tree_valor)
                
                if tie == 'stop' or tie == 'continue':
                    
                    tuplets_pulse_tie = float(tuplets_pulse_dot)
                    tuplets_pulse_dot_tie = float(tuplets_pulse_dot)
                else:
                    tuplets_pulse_tie = round(tuplets_pulse_dot)
                    tuplets_pulse_dot_tie = round(tuplets_pulse_dot)

                if isRest:
                    PULSE.append(-abs(tuplets_pulse_dot_tie))
                    PULSE_TO_KNOW_WHEN_FINISH.append(-abs(tuplets_pulse_dot_tie))
                else:
                    PULSE.append(abs(tuplets_pulse_dot_tie))
                    PULSE_TO_KNOW_WHEN_FINISH.append(abs(tuplets_pulse_dot_tie))
                #print(ratio.denominator, sum(map(lambda x: abs(x), PULSE_TO_KNOW_WHEN_FINISH)), PULSE_TO_KNOW_WHEN_FINISH)     
                if ratio.denominator == sum(map(lambda x: abs(x), PULSE_TO_KNOW_WHEN_FINISH)): # Checar tamanho das tuplets Isso funciona pra tudo???.
                    
                    all_tuplets = om_group()
                    all_tuplets.total_pulses = PULSE
                    all_tuplets.minum_value = names2ratio(durationActual)
                    all_tuplets.total_duration = tuplets_duration
                    PULSE_BY_MEASURE.append(all_tuplets) 
                    PULSE = []
                    PULSE_TO_KNOW_WHEN_FINISH = []
                else:
                    None
         
            else: ## Se não é tuplets
                                
                duration = notes_and_rests.duration
                if isRest:
                    local_om_note = om_note()
                    #print(duration.type)
                    if duration.type == 'complex':
                        ritmo_of_the_note = -1
                    else:
                        ritmo_of_the_note = names2ratio(duration.type)
                    have_dots = duration.dots
                    local_om_note.dots = have_dots  
                    local_om_note.total_duration = -abs(ritmo_of_the_note)
                    local_om_note.rest = True
                    local_om_note.minum_value = names2ratio(ritmo_of_the_note)
                    PULSE_BY_MEASURE.append(local_om_note)
                    PULSE = []
                    PULSE_TO_KNOW_WHEN_FINISH = []
                else:    
                    local_om_note = om_note()
                    if tie == 'stop' or tie == 'continue':
                        local_om_note.tie = True
                    else: 
                        local_om_note.tie = False
                    have_dots = duration.dots
                    local_om_note.rest = False
                    local_om_note.dots = have_dots                    
                    local_om_note.total_duration = names2ratio(duration.type)
                    local_om_note.minum_value = names2ratio(duration.type)
                    PULSE_BY_MEASURE.append(local_om_note)
                    PULSE = []
                    PULSE_TO_KNOW_WHEN_FINISH = []

        new_measure = om_measure() ## Todas as notas do compasso ja foram extraídas
        new_measure.tree = []
        formated_tree = []
        new_measure.tree.append(TimeSignature)
        
        for groups_and_notes in PULSE_BY_MEASURE:
            minor_value = max(list(map(lambda x: x.minum_value, PULSE_BY_MEASURE)))
            #print(groups_and_notes.total_duration)
            #print((minor_value / groups_and_notes.total_duration) * (TimeSignature[1] / 4)) # Compassos com UT menores que 4 nao funcionam ainda
            if isinstance(groups_and_notes, om_group):
                minor_value = max(list(map(lambda x: x.minum_value, PULSE_BY_MEASURE)))
                
                formated_tree.append([round((minor_value / groups_and_notes.total_duration) * (TimeSignature[1] / 4)), groups_and_notes.total_pulses])
                
            else: ## SOU NOTA OU ACORDE OU PAUSA
                #print(list(map(lambda x: x.minum_value, PULSE_BY_MEASURE)))
                minor_value = max(list(map(lambda x: x.minum_value, PULSE_BY_MEASURE)))
                
                correct_value = minor_value / groups_and_notes.total_duration 
                if groups_and_notes.rest:
                    correct_value = -abs(correct_value)
                else:
                    correct_value = abs(correct_value)


                if groups_and_notes.dots == 0:
                    add_dots_to_note = correct_value # Não era pra ser necessario fazer isso
                else:
                    add_dots_to_note = add_dots(correct_value, groups_and_notes.dots, correct_value)
                if groups_and_notes.tie:
                    tie_or_not = float(add_dots_to_note)
                else:
                    tie_or_not = round(add_dots_to_note)
                formated_tree.append(tie_or_not)        
        
        PULSE_BY_MEASURE = []  
        
        new_measure.tree.append(formated_tree)  # salva o compasso formatado
        py2om_voice.tree.append(new_measure.tree)
                
    py2om_om_part.tree.append(py2om_voice.tree)
    py2om_voice.tree = [] # Não tava sendo formatado
    
   
print(lispify(py2om_om_part.tree[0]))

        


