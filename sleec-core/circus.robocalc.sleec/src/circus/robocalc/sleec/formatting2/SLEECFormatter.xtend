/********************************************************************************
 * Copyright (c) 2023 University of York and others
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License 2.0 which is available at
 * http://www.eclipse.org/legal/epl-2.0.
 *
 * SPDX-License-Identifier: EPL-2.0
 *
 * Contributors:
 *  Charlie Burholt - initial definition
 *	Sinem Getir Yaman - initial definition
 *	Maddie Jones - initial definition 
 ********************************************************************************/
package circus.robocalc.sleec.formatting2

import circus.robocalc.sleec.sLEEC.Defblock
import circus.robocalc.sleec.sLEEC.Specification
import circus.robocalc.sleec.services.SLEECGrammarAccess
import com.google.inject.Inject
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import circus.robocalc.sleec.sLEEC.Constant
import circus.robocalc.sleec.sLEEC.Definition
import circus.robocalc.sleec.sLEEC.Measure
import circus.robocalc.sleec.sLEEC.RuleBlock
import java.lang.reflect.Type
import circus.robocalc.sleec.sLEEC.Scale
import circus.robocalc.sleec.sLEEC.Rule
import circus.robocalc.sleec.sLEEC.Trigger
import circus.robocalc.sleec.sLEEC.Response
import circus.robocalc.sleec.sLEEC.Defeater
import circus.robocalc.sleec.sLEEC.MBoolExpr
import circus.robocalc.sleec.sLEEC.BoolComp
import circus.robocalc.sleec.sLEEC.Not
import circus.robocalc.sleec.sLEEC.RelComp
import circus.robocalc.sleec.sLEEC.Atom

class SLEECFormatter extends AbstractFormatter2 {

	@Inject extension SLEECGrammarAccess

	def dispatch void format(Specification specification, extension IFormattableDocument document) {
		specification.defBlock
			.format
			.append[setNewLines(1, 1, 2)]
		specification.ruleBlock.format
	}

	def dispatch void format(Defblock defblock, extension IFormattableDocument document) {
		interior(
			defblock.regionFor.keyword('def_start').append[newLine],
			defblock.regionFor.keyword('def_end').prepend[newLine]
		)[indent]
		defblock.definitions.forEach [
			format
			append[setNewLines(1, 1, 2)]
		]
	}

	def dispatch void format(Definition definition, extension IFormattableDocument document) {
		switch (definition) {
			Measure: format(definition as Measure)
			Constant: format(definition as Scale)
		}
	}

	def dispatch void format(Measure measure, extension IFormattableDocument document) {
		measure.regionFor.keyword(':').surround[oneSpace]
		measure.type.format
	}

	def dispatch void format(Constant constant, extension IFormattableDocument document) {
		constant.regionFor.keyword('=').surround[oneSpace]
	}

	def dispatch void format(Type type, extension IFormattableDocument document) {
		switch (type) {
			Scale: format(type as Scale)
		}
	}

	def dispatch void format(Scale scale, extension IFormattableDocument document) {
		scale.regionFor.keywords('scale', '(', ')').forEach[surround[noSpace]]
		scale.regionFor.keywords(',').forEach [
			prepend[noSpace]
			append[oneSpace]
		]
	}

	def dispatch void format(RuleBlock ruleblock, extension IFormattableDocument document) {
		interior(
			ruleblock.regionFor.keyword('rule_start').append[newLine],
			ruleblock.regionFor.keyword('rule_end').prepend[newLine]
		)[indent]
		ruleblock.rules.forEach [
			format
			append[setNewLines(1, 1, 2)]
		]
	}

	def dispatch void format(Rule rule, extension IFormattableDocument document) {
		rule.regionFor.keywords('when', 'then').forEach[surround[oneSpace]]
		rule.trigger.format
		rule.response.format
		//rule.defeaters.forEach[format]
	}

	def dispatch void format(Trigger trigger, extension IFormattableDocument document) {
		trigger.regionFor.keyword('and').surround[oneSpace]
	}

	def dispatch void format(Response response, extension IFormattableDocument document) {
		response.regionFor.keywords('within', 'not', 'otherwise').forEach[surround[oneSpace]]
		response.constraint.format
	}

	def dispatch void format(Defeater defeater, extension IFormattableDocument document) {
		defeater.regionFor.keywords('unless', 'then').forEach[surround[oneSpace]]
		defeater.response.format
	}
	
	def dispatch void format(MBoolExpr mBoolExpr, extension IFormattableDocument document) {
		switch(mBoolExpr) {
			BoolComp: format(mBoolExpr as BoolComp)
			Not: format(mBoolExpr as Not)
			RelComp: format(mBoolExpr as RelComp)
			Atom: format(mBoolExpr as Atom)
		}
	}
	
	def dispatch void format(BoolComp boolComp, extension IFormattableDocument document) {
		boolComp.left.format
		boolComp.regionFor.ruleCallTo(getBoolOpRule).surround[oneSpace]
		boolComp.right.format
	}
	
	def dispatch format(Not not, extension IFormattableDocument document) {
		not.expr.format
		not.regionFor.keyword('not').append[oneSpace]
	}
	
	def dispatch format(RelComp relComp, extension IFormattableDocument document) {
		relComp.left.format
		relComp.regionFor.ruleCallTo(getRelOpRule).surround[oneSpace]
		relComp.right.format
	}
	
	def dispatch format(Atom atom, extension IFormattableDocument document) {
		atom.regionFor.keyword('(').append[noSpace]
		atom.regionFor.keyword(')').prepend[noSpace]
	}
}
