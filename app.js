async function handleAction(b) {
  const a = b.dataset.action;
  const id = b.dataset.id;

  if (a === 'cancel') {
    render();
    return;
  }

  if (a === 'newSwim' || a === 'editSwim') {
    setTab('results');
    const editor = $('#editor');
    editor.innerHTML = swimForm(state.swims.find(s => s.id === id));
    editor.scrollIntoView({ behavior: 'smooth' });
    return;
  }

  if (a === 'newGoal' || a === 'editGoal') {
    setTab('goals');
    const editor = $('#editor');
    editor.innerHTML = goalForm(state.goals.find(g => g.id === id));
    editor.scrollIntoView({ behavior: 'smooth' });
    return;
  }

  if (a === 'newMeet') {
    setTab('meets');
    $('#editor').innerHTML = `
      <form id="meetForm" class="card formgrid">
        <h2 class="wide">Plan a meet</h2>
        <label>Name<input name="name" required></label>
        <label>Date<input name="date" type="date" required></label>
        <label>Place<input name="place"></label>
        <label>Notes<input name="notes"></label>
        <button class="primary">Save meet</button>
      </form>
    `;
    return;
  }

  if (a === 'newSwimmer' || a === 'editSwimmer') {
    $('#swimmerEditor').innerHTML =
      swimmerForm(state.swimmers.find(s => s.id === id));
    return;
  }

  if (a === 'deleteSwim' || a === 'deleteGoal') {
    const label = a === 'deleteSwim' ? 'result' : 'goal';

    if (confirm('Delete this ' + label + '?')) {
      await remove(a === 'deleteSwim' ? 'swims' : 'goals', id);
      await loadSwimmer();
    }

    return;
  }

  if (a === 'print') {
    window.print();
    return;
  }

  if (a === 'export') {
    const payload = {
      family: { name: state.family.name },
      swimmers: state.swimmers,
      swims: state.swims,
      goals: state.goals,
      meets: state.meets,
      meetEvents: state.meetEvents
    };

    const url = URL.createObjectURL(
      new Blob([JSON.stringify(payload, null, 2)], {
        type: 'application/json'
      })
    );

    const link = document.createElement('a');
    link.href = url;
    link.download = 'family-swim-data.json';
    link.click();

    setTimeout(() => URL.revokeObjectURL(url), 1000);
    return;
  }

  if (a === 'addList') {
    const value = prompt('Add ' + b.dataset.kind);

    if (value?.trim()) {
      await insert('family_lists', {
        family_id: state.family.id,
        kind: b.dataset.kind,
        value: value.trim()
      });

      await loadRoot();
    }

    return;
  }

  if (a === 'addMeetEvent') {
    const event = prompt('Event (for example, 100 Freestyle)');
    if (!event?.trim()) return;

    const course = prompt('Course: SCY, LCM, or SCM', 'SCY') || 'SCY';
    const time = prompt('Target time (optional)');

    await insert('meet_events', {
      meet_id: id,
      event: event.trim(),
      course: course.trim(),
      target: time?.trim() ? parseTime(time) : null
    });

    await loadSwimmer();
    return;
  }

  if (a === 'meetResult') {
    const entry = state.meetEvents.find(x => x.id === id);
    const meet = state.meets.find(m => m.id === entry.meet_id);
    const time = prompt('Result time in seconds or m:ss.ss');

    if (!time) return;

    const seconds = parseTime(time);
    if (!seconds) throw Error('Invalid time.');

    const swim = {
      swimmer_id: state.swimmer.id,
      event: entry.event,
      course: entry.course,
      date: meet.date,
      place: meet.place,
      seconds,
      official: true
    };

    const result = await write('swims', entry.swim_id, swim);

    await update('meet_events', id, {
      swim_id: result[0].id
    });

    await loadSwimmer();
  }
}
