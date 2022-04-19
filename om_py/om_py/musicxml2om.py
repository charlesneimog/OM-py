import html_to_json
from om_py import to_om
import math

def names2ratio (names):
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
        return "Not a valid note"

# =============================================================================

def quialteras_comparation(quialteras):
    if 1 <= quialteras <= 2:
        return 1
    elif 3 <= quialteras <= 4:
        return 2
    elif 5 <= quialteras <= 8:
        return 4
    elif 9 <= quialteras <= 16:
        return 8
    elif 17 <= quialteras <= 32:
        return 16
    elif 33 <= quialteras <= 64:
        return 32
    elif 65 <= quialteras <= 128:
        return 64
    elif 129 <= quialteras <= 256:
        return 128
    else:
        print ("Not a valid note")

# =============================================================================

def add_ratios(first_ratio, second_ratio):
    ratio1 = first_ratio.split('/')   
    ratio2 = second_ratio.split('/')
    numerador_ratio1 = int(float(ratio1[0]))
    denominador_ratio1 = int(float(ratio1[1]))
    numerador_ratio2 = int(float(ratio2[0]))
    denominador_ratio2 = int(float(ratio2[1]))
    numerador_final = numerador_ratio1 * denominador_ratio2 + numerador_ratio2 * denominador_ratio1
    denominador_final = denominador_ratio1 * denominador_ratio2
    return str(numerador_final) + '/' + str(denominador_final)

# =============================================================================

def fix_ratios_values(ratios):
    '''
    Para valores como 0.5/4 ou 0.25/4. O valores serão transformados em 1/8 e 1/16.
    '''
    first_numerator, first_denominator = ratios.split('/')
    numerator = float(first_numerator) * 2
    denominator = float(first_denominator) * 2
    new_numerator = int(float(first_numerator))
    int_denominator = int(float(first_denominator))
    int_numerator = int(float(first_numerator))

    if new_numerator >= 1:
        final_ratio = f'{int_numerator}/{int_denominator}'
    else:
        f'{numerator}/{denominator}'
        ratio = fix_ratios_values(f'{numerator}/{denominator}')
        final_ratio = ratio
    return final_ratio
    
# =============================================================================
def list2ratio(list):
    first_numerator = list[0]
    first_denominator = list[1]
    return f'{first_numerator}/{first_denominator}'

# =============================================================================

def simplify_ratios(ratio):
    numerator, denominator = ratio.split('/')
    gdc =  math.gcd(int(float(numerator)), int(float(denominator)))
    new_numerator = int(int(float(numerator)) / gdc)
    new_denominator = int(int(denominator) / gdc)
    return f'{new_numerator}/{new_denominator}'

# =============================================================================

def sum_list_of_ratios (list_of_ratios):
    cdr_list = list_of_ratios[1:]
    first_ratio = list_of_ratios[0]
    for i in range(len(cdr_list)):
        first_ratio = add_ratios(first_ratio, cdr_list[i])
    return simplify_ratios(first_ratio)

# =============================================================================

def half_of_ratio(ratio):
    numerator, denominator = ratio.split('/')
    denominator = int(float(denominator))
    numerator = int(float(numerator))
    new_numerator = denominator * 2
    new_denominator = numerator * 1
    ratio_with_dot = f'{new_denominator}/{new_numerator}'
    return ratio_with_dot

# =============================================================================

def add_dots(ratio, dots):
    new_ratio = ratio
    list_of_ratios = []
    list_of_ratios.append(ratio)
    for i in range(dots):
        list_of_ratios.append(half_of_ratio(new_ratio))
        new_ratio = half_of_ratio(new_ratio)
    return sum_list_of_ratios(list_of_ratios)

# =============================================================================

def arithm_ser(start, stop, step):
    """ Controi uma serie aritmética como o OM."""
    list = []
    for i in range(start, stop, step):
        t_n = i
        list.append(t_n)
    return list

# =============================================================================

def get_all_cents_inside_measure(todas_as_partes, measure_index, part_index):
    ALL_CENTS = []
    try:
        tamanho_de_dados = len(todas_as_partes[part_index]["measure"][measure_index]["direction"])
    except:
        tamanho_de_dados = 0
    to_loop = arithm_ser(0, tamanho_de_dados + 1, 1)

    for i in to_loop:
        try:
            CENT = todas_as_partes[part_index]["measure"][measure_index]["direction"][i]["direction-type"][0]["words"][0]["_value"]
            ALL_CENTS.append(CENT)
        except:
            None
    return ALL_CENTS

# =============================================================================
def get_all_dynamic_inside_measure(todas_as_partes, measure_index, part_index):
    ALL_DYNAMIC = []
    try:
        tamanho_de_dados = len(todas_as_partes[part_index]["measure"][measure_index]["direction"])
    except:
        tamanho_de_dados = 0
    to_loop = arithm_ser(0, tamanho_de_dados + 1, 1)

    for i in to_loop:
        try:
            DYNAMIC = todas_as_partes[part_index]["measure"][measure_index]["direction"][i]["direction-type"][0]["dynamics"][0]
            ALL_DYNAMIC.append(list(DYNAMIC)[1])
        except:
            None
    return ALL_DYNAMIC


# =============================================================================
def repeat_n(x, n):
    return [x] * n

# =============================================================================
def cents_is_positive(number):
    split_number = number.split('c')
    new_number = split_number[0]
    if int(split_number[0]) >= 0:
        return '+{number}'.format(number = new_number)
    else:
        return new_number

# =============================================================================
def accidental_to_number(accidental):
    if accidental == 'flat':
        return 'b'
    elif accidental == 'sharp':
        return '#' 
    else:
        return ''
    

# =============================================================================

def musicxml2om(musicxml_file):
    with open(musicxml_file, 'r') as f:
        html_string = f.read()

    output_json = html_to_json.convert(html_string)

    keys = output_json["score-partwise"] #  Pega toda a partitura e seus dados.

    todas_as_partes = keys[0]["part"] #  Pega toda a partitura e seus dados.

    tamanho_partes = len(todas_as_partes)

    ##print(f'There is {tamanho_partes} voices!')

    PITCH_NOTE = []
    PITCHES_BY_MEASURE = []
    PITCHES_BY_VOICES = []

    RHYTHMIC_RATIOS = []
    RHYTHMIC_BY_MEASURE = []
    RHYTHMIC_BY_VOICE = []
    TIE_VALUE = []

    DYNAMIC_VALUE = []
    DYNAMICS_BY_MEASURE = []
    DYNAMICS_BY_VOICE = []


    for partes in range(len(todas_as_partes)): ## =================================================================================== Voz por Voz.
        DYNAMICS_BY_MEASURE = []   
        RHYTHMIC_BY_MEASURE = []
        PITCHES_BY_MEASURE = []
        parte = keys[0]["part"][partes]["measure"] ## Seleciona todos os compassos da parte da vez
        quantidade_de_compassos = len(parte) ## Ve quantidade de compassos
        part_number = partes + 1 
        
        for compassos in range(len(parte)): # =================================================================================== Compassos por compassos.
            
            DYNAMIC_INDEX = 0
            CENT_INDEX = 0
            compasso_number = compassos + 1
            try: 
                FIRST_NOTE_NEXT_MEASURE = keys[0]["part"][partes]["measure"][compasso_number]["note"][0]
            except:
                FIRST_NOTE_NEXT_MEASURE = [] #O que colocar aqui???
            
            todas_as_notas_do_compasso  = keys[0]["part"][partes]["measure"][compassos]["note"] ## Todas notas do compasso
            quantidade_de_notas = len(todas_as_notas_do_compasso) ## Quantidade de notas no compasso
            time = keys[0]["part"][partes]["measure"][compassos]
            try:
                TIME_BEATS = time["attributes"][0]["time"][0]["beats"][0]["_value"][0]
                TIME_BEATS_TYPE = time["attributes"][0]["time"][0]["beat-type"][0]["_value"][0]
            except:
                TIME_BEATS = TIME_BEATS
                TIME_BEATS_TYPE = TIME_BEATS_TYPE
            RHYTHMIC_RATIOS = []
            PITCH_NOTE = []
            DYNAMIC_VALUE = []

            CENTS_DO_COMPASSO = get_all_cents_inside_measure(todas_as_partes, compassos, partes)
            DYNAMICS_OF_MEASURE = get_all_dynamic_inside_measure(todas_as_partes, compassos, partes)

    # =================================================================================== Para evitar erros.

            if CENTS_DO_COMPASSO == []:
                    CENTS_DO_COMPASSO = repeat_n(0, quantidade_de_notas)
            else:
                CENTS_DO_COMPASSO = CENTS_DO_COMPASSO

    # =================================================================================== Para evitar erros.

            if DYNAMICS_OF_MEASURE == []:
                DYNAMICS_OF_MEASURE = repeat_n('nil', quantidade_de_notas)
            else:
                DYNAMICS_OF_MEASURE = DYNAMICS_OF_MEASURE
            
            for notas in range(quantidade_de_notas): ## =============================================================================== NOTA POR NOTA
                note_number = notas + 1
                #print('\n')
                #print(f'ESTOU NA PARTE {part_number}, NO COMPASSO {compasso_number}, na NOTA {note_number}')
                try:
                    accidental = accidental_to_number(keys[0]["part"][partes]["measure"][compassos]["note"][notas]["accidental"][0]["_value"])
                except:
                    accidental = accidental_to_number(' ')
                
                notes_or_rest = keys[0]["part"][partes]["measure"][compassos]["note"][notas]
                duration_name = notes_or_rest["type"][0]["_value"]
                
    ## ===================================================================================================================================================
    ## ===================================================================================================================================================
                
                try: ### QUANDO FOR ALTURAS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! **QUANDO FOR ALTURAS**
                    note = notes_or_rest["pitch"][0]["step"][0]["_value"]
                    note_octave = notes_or_rest["pitch"][0]["octave"][0]["_value"]
                    
                    
                    try: # ===================================================================== QUANDO FOR ALTURAS COM QUIALTERAS =========
                        actual_notes = int(notes_or_rest["time-modification"][0]["actual-notes"][0]["_value"])
                        normal_value = int(notes_or_rest["time-modification"][0]["normal-notes"][0]["_value"])
                        normal_type = names2ratio(notes_or_rest["time-modification"][0]["normal-type"][0]["_value"])
                        figure_rhythm_number = names2ratio(duration_name)
                        
                        
                        try: # ===================================== QUANDO FOR ALTURAS COM QUIALTERAS E LIGADURA =====================================
                            ligadura = notes_or_rest["tie"][0]["_attributes"]["type"]
                            if ligadura == "start": # ALTURA COM QUIALTERA E LIGADURA COMECANDO A LIGADURA
                                final_numerator = normal_value / figure_rhythm_number
                                final_ratio = simplify_ratios(fix_ratios_values(f'{final_numerator}/{actual_notes}'))
                                try:
                                    note_dots = notes_or_rest["dot"]
                                    quantos_pontos = len(note_dots)
                                    final_ratio = simplify_ratios(add_dots(final_ratio, quantos_pontos))
                                    MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                    CENT_INDEX += 1
                                    note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))
                                    try:
                                        dynamic = DYNAMICS_OF_MEASURE[DYNAMIC_INDEX]
                                        DYNAMIC_VALUE.append(dynamic)
                                        DYNAMIC_INDEX += 1
                                    except:
                                        None
                                    PITCH_NOTE.append(note_name)
                                    TIE_VALUE.append(final_ratio)
                                    #print(f'Sou uma {note_name}, finalizando/no meio da ligadura dentro de quialtera e tenho ponto, meu valor final é: {final_ratio}')
                                except:
                                    MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                    CENT_INDEX += 1
                                    note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))

                                    try:
                                        dynamic = DYNAMICS_OF_MEASURE[DYNAMIC_INDEX]
                                        DYNAMIC_INDEX += 1
                                        DYNAMIC_VALUE.append(dynamic)
                                    except:
                                        None
                                    PITCH_NOTE.append(note_name)
                                    TIE_VALUE.append(final_ratio)
                                    #print(f'Sou uma {note_name}, finalizando/no meio da ligadura dentro de quialtera e tenho ponto, meu valor final é: {final_ratio}')
                                
                            elif ligadura == "stop": # ALTURA COM QUIALTERA E LIGADURA NO MEIO OU FINALIZANDO A LIGADURA
                                final_numerator = normal_value / figure_rhythm_number
                                final_ratio = simplify_ratios(fix_ratios_values(f'{final_numerator}/{actual_notes}'))
                                try:
                                    notes_or_rest["dot"]
                                    quantos_pontos = len(notes_or_rest["dot"])
                                    final_ratio = simplify_ratios(add_dots(final_ratio, quantos_pontos))
                                    #print('Sou uma nota finalizando/no meio da ligadura dentro de quialtera e tenho ponto. Meu valor é: ', final_ratio)
                                    TIE_VALUE.append(final_ratio)
                                except:
                                    TIE_VALUE.append(final_ratio)
                                    #print('Sou uma nota finalizando/no meio da ligadura dentro de quialtera e nao tenho ponto, meu valor é', final_ratio)

                                # Se a proxima no for INICIAR uma ligadura, a soma de todas as ligadas anteriormente serão adicionadas ao final da nota
                                try: # tenta ver se a proxima nota tem ligadura
                                    if quantidade_de_notas == (notas + 1): # Se isso for TRUE significa que estamos na ultima nota do compasso
                                        next_tie = FIRST_NOTE_NEXT_MEASURE["tie"][0]["_attributes"]["type"] 
                                    else: # Nao estamos na ultima nota do compasso    
                                        next_notes_or_rest = keys[0]["part"][partes]["measure"][compassos]["note"][notas + 1]
                                        next_tie = next_notes_or_rest["tie"][0]["_attributes"]["type"] 
                                        
                                    if next_tie != "stop": # É a ultima nota do compasso:
                                        RHYTHMIC_RATIOS.append(simplify_ratios(sum_list_of_ratios(TIE_VALUE)))
                                        #print('Valor final da ligadura:', simplify_ratios(sum_list_of_ratios(TIE_VALUE)))
                                        TIE_VALUE = []
                                    else:
                                        None 
                                except: # Se tudo der errado, significa que a proxima nota nao é ligada, entao soma-se todos os valores e adiciona a lista final de valores
                                    RHYTHMIC_RATIOS.append(simplify_ratios(sum_list_of_ratios(TIE_VALUE)))
                                    #print('Valor final da ligadura:', simplify_ratios(sum_list_of_ratios(TIE_VALUE)))
                                    TIE_VALUE = [] # apos adicionar limpa o valor das ligaduras.
        
                                
                        except: # ===================================== QUANDO FOR ALTURAS COM QUIALTERAS SEM LIGADURA =============================

                            final_numerator = normal_value / figure_rhythm_number
                            final_ratio = simplify_ratios(fix_ratios_values(f'{final_numerator}/{actual_notes}'))
                            try:
                                notes_or_rest["dot"]
                                quantos_pontos = len(notes_or_rest["dot"])
                                final_ratio = simplify_ratios(add_dots(final_ratio, quantos_pontos))
                                MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                CENT_INDEX += 1
                                note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))
                                PITCH_NOTE.append(note_name)
                                try:
                                    dynamic = DYNAMICS_OF_MEASURE[DYNAMIC_INDEX]
                                    DYNAMIC_INDEX += 1
                                    DYNAMIC_VALUE.append(dynamic)
                                except:
                                    None
                                
                                #print(f'Sou uma {note_name}, finalizando/no meio da ligadura dentro de quialtera e tenho ponto, meu valor final é: {final_ratio}')
                            except:
                                MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                CENT_INDEX += 1
                                note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))
                                PITCH_NOTE.append(note_name)
                                try:
                                    dynamic = DYNAMICS_OF_MEASURE[DYNAMIC_INDEX]
                                    DYNAMIC_INDEX += 1
                                    DYNAMIC_VALUE.append(dynamic)
                                except:
                                    None
                                #print(f'Sou uma {note_name}, finalizando/no meio da ligadura dentro de quialtera e tenho ponto, meu valor final é: {final_ratio}')
                            RHYTHMIC_RATIOS.append(final_ratio) 
                        
                    #=============================================== QUANDO FOR ALTURAS SEM QUIALTERAS 
                    except: 
                        octave = notes_or_rest["pitch"][0]["octave"][0]["_value"]
                        

                        try: # ===================================== QUANDO FOR ALTURAS SEM QUIALTERAS LIGADAS =====================

                            ligadura = notes_or_rest["tie"][0]["_attributes"]["type"]
                            if ligadura == "start": ## INICIANDO A LIGADURA 
                                figure_rhythm_number = names2ratio(duration_name) 
                                NOTE_VALUE = int(TIME_BEATS_TYPE) / figure_rhythm_number                
                                final_ratio = f'{NOTE_VALUE}/{TIME_BEATS_TYPE}'
                                MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))
                                try:
                                    notes_or_rest["dot"] # COM PONTO
                                    quantos_pontos = len(notes_or_rest["dot"]) # QUANTOS PONTOS TEM
                                    final_ratio = simplify_ratios(add_dots(final_ratio, quantos_pontos))
                                    MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                    CENT_INDEX = CENT_INDEX + 1
                                    note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))
                                    
                                    
                                    try:
                                        dynamic = DYNAMICS_OF_MEASURE[DYNAMIC_INDEX]
                                        DYNAMIC_INDEX += 1
                                        DYNAMIC_VALUE.append(dynamic)
                                    except:
                                        None
                                    
                                    PITCH_NOTE.append(note_name)
                                    TIE_VALUE.append(final_ratio)
                                    #print(f'Sou uma {note_name}, finalizando/no meio da ligadura dentro de quialtera e tenho ponto, meu valor final é: {final_ratio}')
                                except:
                                    final_ratio = simplify_ratios(fix_ratios_values(final_ratio))
                                    MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                    CENT_INDEX += 1
                                    note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))
                                    
                                    try:
                                        dynamic = DYNAMICS_OF_MEASURE[DYNAMIC_INDEX]
                                        DYNAMIC_INDEX += 1
                                        DYNAMIC_VALUE.append(dynamic)
                                    except:
                                        None
                                    PITCH_NOTE.append(note_name)
                                    TIE_VALUE.append(final_ratio)
                                    #print(f'Sou uma {note_name}, finalizando/no meio da ligadura dentro de quialtera e tenho ponto, meu valor final é: {final_ratio}')


                            elif ligadura == "stop":
                                
                                figure_rhythm_number = names2ratio(duration_name) 
                                NOTE_VALUE = int(TIME_BEATS_TYPE) / figure_rhythm_number                
                                final_ratio = f'{NOTE_VALUE}/{TIME_BEATS_TYPE}'
                                
                                try: # ========================================================================== TEM PONTO
                                    notes_or_rest["dot"]
                                    quantos_pontos = len(notes_or_rest["dot"])
                                    final_ratio = simplify_ratios(add_dots(final_ratio, quantos_pontos))
                                    TIE_VALUE.append(final_ratio)
                                    #print('Sou uma nota no meio de uma ligadura, com ponto, sem QUIALTERAS, meu valor é:', final_ratio)
                                except: # ========================================================================== SEM PONTO
                                    final_ratio = simplify_ratios(fix_ratios_values(final_ratio))
                                    TIE_VALUE.append(final_ratio)
                                    #print('Sou uma nota no meio de uma ligadura, sem ponto, sem QUIALTERAS, meu valor é:', final_ratio)
                                
                                try: ## Essa parte ve se a proxima ligadura é uma nova ligadura ou a mesma
                                    if quantidade_de_notas == (notas + 1): # Se isso for TRUE significa que estamos na ultima nota do compasso
                                        next_tie = FIRST_NOTE_NEXT_MEASURE["tie"][0]["_attributes"]["type"] 
                                    else: # Nao estamos na ultima nota do compasso    
                                        next_notes_or_rest = keys[0]["part"][partes]["measure"][compassos]["note"][notas + 1]
                                        next_tie = next_notes_or_rest["tie"][0]["_attributes"]["type"]   # É a ultima nota do compasso:
                                    if next_tie != "stop":
                                        RHYTHMIC_RATIOS.append(sum_list_of_ratios(TIE_VALUE))
                                        #print('Valor final da ligadura:', sum_list_of_ratios(TIE_VALUE))
                                        TIE_VALUE = []
                                    else:
                                        None 
                                except:
                                    RHYTHMIC_RATIOS.append(sum_list_of_ratios(TIE_VALUE))
                                    #print('Valor final da ligadura:', sum_list_of_ratios(TIE_VALUE))
                                    TIE_VALUE = []
                                                    
                        
                        except: # ===================================== QUANDO FOR ALTURAS SEM QUIALTERAS SEM LIGADURAS ============================
                            #PITCH_NOTE.append(note + str(octave)) 
                            
                            figure_rhythm_number = names2ratio(duration_name) 
                            NOTE_VALUE = int(TIME_BEATS_TYPE) / figure_rhythm_number                      
                            final_ratio = fix_ratios_values(f'{NOTE_VALUE}/{TIME_BEATS_TYPE}')
                            
                            try:
                                notes_or_rest["dot"]
                                quantos_pontos = len(notes_or_rest["dot"])
                                final_ratio = add_dots(final_ratio, quantos_pontos)
                                
                                MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                CENT_INDEX += 1
                                note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))
                                
                                try:
                                    dynamic = DYNAMICS_OF_MEASURE[DYNAMIC_INDEX]
                                    DYNAMIC_INDEX += 1
                                    DYNAMIC_VALUE.append(dynamic)
                                except:
                                    None
                                PITCH_NOTE.append(note_name)
                                RHYTHMIC_RATIOS.append(final_ratio)
                                #print(f'Sou uma {note_name}, finalizando/no meio da ligadura dentro de quialtera e tenho ponto, meu valor final é: {final_ratio}')
                            except:
                                MICROTON = CENTS_DO_COMPASSO[CENT_INDEX]
                                CENT_INDEX += 1
                                note_name = '{0}{1}{2}{3}'.format(note, accidental, note_octave, cents_is_positive(MICROTON))
                                try: #Precaution
                                    dynamic = DYNAMICS_OF_MEASURE[DYNAMIC_INDEX]
                                    DYNAMIC_INDEX += 1
                                    DYNAMIC_VALUE.append(dynamic)
                                except:
                                    None
                                PITCH_NOTE.append(note_name)
                                RHYTHMIC_RATIOS.append(final_ratio)
                                #print(f'Sou uma {note_name}, finalizando/no meio da ligadura dentro de quialtera e tenho ponto, meu valor final é: {final_ratio}')
                
                except: ### ========================================================================== Quando a nota é PAUSE pausa executa isso!
        
                    try: # ======================================================================================= Pausas com quialteras
                        
                        actual_notes = int(notes_or_rest["time-modification"][0]["actual-notes"][0]["_value"])
                        normal_value = int(notes_or_rest["time-modification"][0]["normal-notes"][0]["_value"])
                        normal_type = names2ratio(notes_or_rest["time-modification"][0]["normal-type"][0]["_value"])
                        figure_rhythm_number = names2ratio(duration_name)
                        final_numerator = normal_value / figure_rhythm_number
                        final_ratio = '-{ratio}'.format(ratio = simplify_ratios(fix_ratios_values(f'{final_numerator}/{actual_notes}')))
                        #print('Sou uma pausa com quialtera, meu valor é: ', final_ratio)      
                        RHYTHMIC_RATIOS.append(final_ratio)
                        
                    except: # ===================================================================================== Pausas Sem quialteras 
                        figure_rhythm_number = '-1/{ratio}'.format(ratio = names2ratio(duration_name))
                        #print('Sou uma pausa sem quialtera, meu valor é: ', figure_rhythm_number)
                        RHYTHMIC_RATIOS.append(figure_rhythm_number)

                
            RHYTHMIC_BY_MEASURE.append(RHYTHMIC_RATIOS)
            PITCHES_BY_MEASURE.append(PITCH_NOTE) 
            DYNAMICS_BY_MEASURE.append(DYNAMIC_VALUE)

        
        RHYTHMIC_BY_VOICE.append(RHYTHMIC_BY_MEASURE) 
        PITCHES_BY_VOICES.append(PITCHES_BY_MEASURE) 
        DYNAMICS_BY_VOICE.append(DYNAMICS_BY_MEASURE) 

    to_om(list(RHYTHMIC_BY_VOICE))
    to_om(list(PITCHES_BY_VOICES))
    to_om(list(DYNAMICS_BY_VOICE))

# =============================================================================