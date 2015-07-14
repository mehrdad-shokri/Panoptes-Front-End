React = require 'react'

Summary = React.createClass
  displayName: 'SurveySummary'
  render: ->
    null

Chooser = React.createClass
  displayName: 'Chooser'

  getDefaultProps: ->
    task: null
    onChoose: Function.prototype

  getInitialState: ->
    filters: {}

  getFilteredChoices: ->
    for choiceID in @props.task.choicesOrder
      choice = @props.task.choices[choiceID]
      rejected = false
      for filterID, filterValue of @state.filters
        if filterValue not in choice.characteristics[filterID]
          rejected = true
          break
      if rejected
        continue
      else
        choiceID

  render: ->
    <div className="survey-chooser">
      {for characteristicID in @props.task.characteristicsOrder
        characteristic = @props.task.characteristics[characteristicID]
        <div key={characteristicID}>
          <label>
            {characteristic.label}{' '}
            <select value={@state.filters[characteristicID] ? ''} onChange={@handleFilter.bind this, characteristicID}>
              <option value="">(Any)</option>
              {for valueID in characteristic.valuesOrder
                value = characteristic.values[valueID]
                <option value={valueID}>{value.label}</option>}
            </select>
          </label>
        </div>}

      {for choiceID in @getFilteredChoices()
        choice = @props.task.choices[choiceID]
        <div key={choiceID}>
          <button type="button" onClick={@props.onChoose.bind this, choiceID}>{choice.label}</button>
        </div>}
    </div>

  handleFilter: (characteristicID, e) ->
    value = e.target.value
    if e.target.value is ''
      delete @state.filters[characteristicID]
    else
      @state.filters[characteristicID] = value
    @setState filters: @state.filters

ChoiceDetails = React.createClass
  displayName: 'ChoiceDetails'

  getDefaultProps: ->
    task: null
    choiceID: ''
    onConfirm: Function.prototype
    onCancel: Function.prototype

  getInitialState: ->
    answers: {}

  render: ->
    choice = @props.task.choices[@props.choiceID]
    <div className="survey-choice-details">
      <div>{choice.label}</div>
      <div>{choice.description}</div>
      {for questionID in @props.task.questionsOrder
        question = @props.task.questions[questionID]
        inputType = if question.multiple
          'checkbox'
        else
          'radio'
        <div key={questionID}>
          {question.label}{' '}
          {for answerID in question.answersOrder
            answer = question.answers[answerID]
            isChecked = if question.multiple
              answerID in (@state.answers[questionID] ? [])
            else
              answerID is @state.answers[questionID]
            <label key={answerID}>
              <input type={inputType} checked={isChecked} onChange={@handleAnswer.bind this, questionID, answerID} />{' '}
              {answer.label}
            </label>}
        </div>}
      <button type="button" onClick={@props.onCancel}>Cancel</button>
      <button type="button" onClick={@handleIdentification}>Identify</button>
    </div>

  handleAnswer: (questionID, answerID, e) ->
    if @props.task.questions[questionID].multiple
      @state.answers[questionID] ?= []
      if e.target.checked
        @state.answers[questionID].push answerID
      else
        @state.answers[questionID].splice @state.answers[questionID].indexOf(answerID), 1
    else
      @state.answers[questionID] = if e.target.checked
        answerID
      else
        null
    @setState answers: @state.answers

  handleIdentification: ->
    @props.onConfirm @props.choiceID, @state.answers

module.exports = React.createClass
  displayName: 'SurveyTask'

  statics:
    Editor: null
    Summary: Summary

    getDefaultTask: ->
      type: 'survey'
      characteristics: []
      choices: []

    getTaskText: (task) ->
      '(Survey)'

    getDefaultAnnotation: ->
      value: []

  getDefaultProps: ->
    task: null
    annotation: null
    onChange: Function.prototype

  getInitialState: ->
    selectedChoiceID: ''

  render: ->
    <div className="survey-task">
      {if @state.selectedChoiceID is ''
        <Chooser task={@props.task} onChoose={@handleChoice} />
      else
        <ChoiceDetails task={@props.task} choiceID={@state.selectedChoiceID} onCancel={@clearSelection} onConfirm={@handleAnnotation} />}
    </div>

  handleChoice: (choiceID) ->
    @setState selectedChoiceID: choiceID

  clearSelection: ->
    @setState selectedChoiceID: ''

  handleAnnotation: (choice, details, e) ->
    @clearSelection()
    @props.annotation.value ?= []
    @props.annotation.value.push {choice, details}
    @props.onChange e
