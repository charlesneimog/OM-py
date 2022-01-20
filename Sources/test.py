
from pymusicxml import *
from om_py import to_om
Score([
  PartGroup([
      
    Part('Piano 1', [
            
         Measure([
                  Tuplet([ 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                        ], (3, 2)),
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),
                  Tuplet([ 
                    Note('C4', 0.75, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 1.0, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                        ], (7, 4)),
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),

                 ], time_signature=(4,  4, )),

         Measure([
                  Tuplet([ 
                    Note('C4', 0.75, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 1.0, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                        ], (7, 4)),
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),
                  Rest(1),
                  Tuplet([ 
                    Note('C4', 0.75, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 1.0, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                        ], (7, 4)),

                 ], time_signature=(4,  8, )),

         Measure([
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),

                 ], time_signature=(2,  4, )),

         Measure([
                  Tuplet([ 
                    Note('C4', 0.75, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 1.0, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                        ], (7, 4)),
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),

                 ],  ),

         Measure([
                  Tuplet([ 
                    Note('C4', 0.75, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 1.0, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                        ], (7, 4)),
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),

                 ],  ),

         Measure([
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),
                  Tuplet([ 
                    Note('C4', 0.75, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 1.0, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                        ], (7, 4)),

                 ],  ),

         Measure([
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),
                  BeamedGroup([ 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.5, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                    Note('C4', 0.25, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')], velocity=100), 
                        ]),

                 ],  ),

         Measure([
                  Tuplet([ 
                    Note('C4', 0.75, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                    Note('C4', 1.0, ties=None, directions=[TextAnnotation('~B0,64'), TextAnnotation('(0c)', '5.0')]), 
                        ], (7, 4)),
                  Rest(1),

                 ],  ),

    ]),

  ])
], title='Musicxml teste', composer='Charles K. Neimog').export_to_file(r'C:\Users\charl\OneDrive_usp.br\Documents\OpenMusic\out-files\Musicxml teste.musicxml')
to_om(r'C:\Users\charl\OneDrive_usp.br\Documents\OpenMusic\out-files\Musicxml teste.musicxml')

