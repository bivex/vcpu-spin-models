	switch (t->back) {
	default: Uerror("bad return move");
	case  0: goto R999; /* nothing to undo */

		 /* CLAIM liveness */
;
		;
		
	case 4: // STATE 6
		;
		p_restor(II);
		;
		;
		goto R999;

		 /* PROC :init: */

	case 5: // STATE 1
		;
		now.pcode[0].enc_opcode = trpt->bup.oval;
		;
		goto R999;

	case 6: // STATE 2
		;
		now.pcode[0].enc_operand = trpt->bup.oval;
		;
		goto R999;

	case 7: // STATE 3
		;
		now.pcode[1].enc_opcode = trpt->bup.oval;
		;
		goto R999;

	case 8: // STATE 4
		;
		now.pcode[1].enc_operand = trpt->bup.oval;
		;
		goto R999;

	case 9: // STATE 5
		;
		now.pcode[2].enc_opcode = trpt->bup.oval;
		;
		goto R999;

	case 10: // STATE 6
		;
		now.pcode[2].enc_operand = trpt->bup.oval;
		;
		goto R999;

	case 11: // STATE 7
		;
		now.pcode[3].enc_opcode = trpt->bup.oval;
		;
		goto R999;

	case 12: // STATE 8
		;
		now.pcode[3].enc_operand = trpt->bup.oval;
		;
		goto R999;

	case 13: // STATE 9
		;
		;
		delproc(0, now._nr_pr-1);
		;
		goto R999;

	case 14: // STATE 10
		;
		p_restor(II);
		;
		;
		goto R999;

		 /* PROC RollingVCPU */
;
		;
		
	case 16: // STATE 3
		;
		now.handler_id = trpt->bup.ovals[1];
		((P0 *)_this)->_2_1_raw_op = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;

	case 17: // STATE 4
		;
		now.vkey = trpt->bup.oval;
		;
		goto R999;

	case 18: // STATE 21
		;
		now.step_count = trpt->bup.ovals[3];
		now.vip = trpt->bup.ovals[2];
		now.vstack[ Index(now.vsp, 16) ] = trpt->bup.ovals[1];
		now.vsp = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 4);
		goto R999;

	case 19: // STATE 21
		;
		now.step_count = trpt->bup.ovals[3];
		now.vip = trpt->bup.ovals[2];
		now.vsp = trpt->bup.ovals[1];
		now.vstack[ Index((now.vsp+1), 16) ] = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 4);
		goto R999;

	case 20: // STATE 21
		;
		now.step_count = trpt->bup.ovals[3];
		now.vip = trpt->bup.ovals[2];
		now.vsp = trpt->bup.ovals[1];
		now.vstack[ Index((now.vsp+1), 16) ] = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 4);
		goto R999;

	case 21: // STATE 21
		;
		now.step_count = trpt->bup.ovals[2];
		now.vip = trpt->bup.ovals[1];
		now.vm_running = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 3);
		goto R999;

	case 22: // STATE 21
		;
		now.step_count = trpt->bup.ovals[1];
		now.vip = trpt->bup.ovals[0];
		;
		ungrab_ints(trpt->bup.ovals, 2);
		goto R999;
;
		;
		
	case 24: // STATE 28
		;
		p_restor(II);
		;
		;
		goto R999;
	}

