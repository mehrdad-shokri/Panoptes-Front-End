apiClient = require '../api/client'

# This is just a blank image for testing drawing tools.
BLANK_IMAGE = ['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAoAAAAHgAQMAAAA',
  'PH06nAAAABlBMVEXMzMyWlpYU2uzLAAAAPUlEQVR4nO3BAQ0AAADCoPdPbQ43oAAAAAAAAAAAAA',
  'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgzwCX4AAB9Dl2RwAAAABJRU5ErkJggg=='].join ''

workflow = apiClient.type('workflows').create
  id: 'MOCK_WORKFLOW_FOR_CLASSIFIER'

  first_task: 'survey'
  tasks:
    survey:
      type: 'survey'
      characteristicsOrder: ['pa', 'co']
      characteristics:
        pa:
          label: 'Pattern'
          valuesOrder: ['so', 'sp', 'st', 'ba']
          values:
            so:
              label: 'Solid'
            sp:
              label: 'Spots'
            st:
              label: 'Stripes'
            ba:
              label: 'Bands'
        co:
          label: 'Color'
          valuesOrder: ['wh', 'ta', 're', 'br', 'bl', 'gr']
          values:
            wh:
              label: 'White'
            ta:
              label: 'Tan'
            re:
              label: 'Red'
            br:
              label: 'Brown'
            bl:
              label: 'Black'
            gr:
              label: 'Green'

      choicesOrder: ['aa', 'ar', 'to']
      choices:
        aa:
          label: 'Aardvark'
          description: 'Basically a long-nose rabbit'
          characteristics:
            pa: ['so']
            co: ['ta', 'br']
        ar:
          label: 'Armadillo'
          description: 'A little rolly dude'
          characteristics:
            pa: ['so', 'st']
            co: ['ta', 'br']
        to:
          label: 'Tortoise'
          description: 'Little green house with legs'
          characteristics:
            pa: ['so']
            co: ['gr']

      questionsOrder: ['ho', 'be']
      questions:
        ho:
          multiple: false
          label: 'How many?'
          answersOrder: ['one', 'two', 'many']
          answers:
            one:
              label: '1'
            two:
              label: '2'
            many:
              label: '3+'
        be:
          multiple: true
          label: 'Any activity?'
          answersOrder: ['mo', 'ea', 'in']
          answers:
            mo:
              label: 'Moving'
            ea:
              label: 'Eating'
            in:
              label: 'Interacting'

    draw:
      type: 'drawing'
      instruction: 'Draw something.'
      help: '''
        Do this:
        * Pick a tool
        * Draw something
      '''
      tools: [
        {
          type: 'point'
          label: 'Point'
          color: 'red'
          details: [{
            type: 'single'
            question: 'Cool?'
            answers: [
              {label: 'Yeah, this is pretty cool, in fact I’m going to write a big long sentence describe just how cool I think it is.'}
              {label: 'Nah'}
            ]
          }, {
            type: 'multiple'
            question: 'Cool stuff?'
            answers: [
              {label: 'Ice'}
              {label: 'Snow'}
            ]
          }]
        }
        {type: 'line', label: 'Line', color: 'yellow'}
        {type: 'rectangle', label: 'Rectangle', color: 'lime'}
        {type: 'polygon', label: 'Polygon', color: 'cyan'}
        {type: 'circle', label: 'Circle', color: 'blue'}
        {type: 'ellipse', label: 'Ellipse', color: 'magenta'}
      ]
      next: 'cool'

    cool:
      type: 'single'
      question: 'Is this cool?'
      answers: [
        {label: 'Yeah'}
        {label: 'Nah'}
      ]
      next: 'features'

    features:
      type: 'multiple'
      question: 'What cool features are present?'
      answers: [
        {label: 'Cold water'}
        {label: 'Snow'}
        {label: 'Ice'}
        {label: 'Sunglasses'}
      ]

subject = apiClient.type('subjects').create
  id: 'MOCK_SUBJECT_FOR_CLASSIFIER'

  locations: [
    {'image/jpeg': 'http://lorempixel.com/1500/1000/animals/1'}
    {'image/jpeg': 'http://lorempixel.com/1500/1000/animals/2'}
    {'image/jpeg': 'http://lorempixel.com/1500/1000/animals/3'}
  ]

  metadata:
    'Capture date': '5 Feb, 2015'
    'Region': 'Chicago, IL'

  expert_classification_data:
    annotations: [{
      task: 'draw'
      value: [{
        tool: 0
        x: 50
        y: 50
        frame: 0
      }, {
        tool: 0
        x: 150
        y: 50
        frame: 0
      }]
    }, {
      task: 'cool'
      value: 0
    }, {
      task: 'features'
      value: [0, 2]
    }]

classification = apiClient.type('classifications').create
  annotations: []
  metadata: {}
  links:
    project: 'NO_PROJECT'
    workflow: workflow.id
    subjects: [subject.id]
  _workflow: workflow # TEMP
  _subjects: [subject] # TEMP

module.exports = {workflow, subject, classification}
window.mockClassifierData = module.exports
