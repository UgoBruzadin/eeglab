function [EEG, acronym] = pipe_headmodel100(EEG)

    EEG = pop_select( EEG,'nochannel',[8	14	17	21	25	48	49	56	63	64	68	69	73	74	81	82	88	89	94	95	99	107	113	119	120	125	126	127	128]); 
    acronym = 'HM100';
end