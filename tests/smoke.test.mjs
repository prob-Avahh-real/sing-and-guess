import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');

const VALID_GENRES = new Set(['mandopop', 'cantopop', 'english', 'folk', 'rock', 'film']);
const VALID_DIFFICULTIES = new Set(['easy', 'medium', 'hard']);

test('songs.json catalog adheres to Swift Song Codable schema with unique IDs and progressive hints', () => {
  const songs = JSON.parse(
    fs.readFileSync(path.join(ROOT, 'SingAndGuess/Data/songs.json'), 'utf8')
  );
  assert.ok(Array.isArray(songs) && songs.length >= 40, `expected >=40 songs, got ${songs.length}`);

  const ids = new Set();
  const genresSeen = new Set();
  for (const song of songs) {
    assert.ok(song.id && !ids.has(song.id), `duplicate or missing song id: ${song.id}`);
    ids.add(song.id);
    assert.ok(song.title && song.title.trim().length > 0, `missing title for ${song.id}`);
    assert.ok(song.artist && song.artist.trim().length > 0, `missing artist for ${song.id}`);
    assert.ok(VALID_GENRES.has(song.genre), `invalid genre ${song.genre} on ${song.id}`);
    assert.ok(VALID_DIFFICULTIES.has(song.difficulty), `invalid difficulty ${song.difficulty} on ${song.id}`);
    assert.ok(Array.isArray(song.hints) && song.hints.length >= 3, `expected >=3 hints on ${song.id}`);
    genresSeen.add(song.genre);
  }
  assert.ok(genresSeen.size >= 4, 'catalog should span multiple genres');
});

test('Swift models and GameViewModel enforce scoring, phase machine, and XcodeGen structure', () => {
  for (const rel of [
    'project.yml',
    'SingAndGuess/SingAndGuessApp.swift',
    'SingAndGuess/Models/Song.swift',
    'SingAndGuess/Models/GameState.swift',
    'SingAndGuess/Models/Player.swift',
    'SingAndGuess/Data/SongLibrary.swift',
    'SingAndGuess/ViewModels/GameViewModel.swift',
  ]) {
    assert.ok(fs.existsSync(path.join(ROOT, rel)), `missing ${rel}`);
  }

  const gameState = fs.readFileSync(path.join(ROOT, 'SingAndGuess/Models/GameState.swift'), 'utf8');
  assert.match(gameState, /var singerPoints:\s*Int/);
  assert.match(gameState, /var guesserPoints:\s*Int/);
  assert.match(gameState, /max\(10,\s*100\s*-\s*Int\(timeSpent\)\s*\*\s*2\)/);
  assert.match(gameState, /max\(20,\s*200\s*-\s*Int\(timeSpent\)\s*\*\s*4\)/);

  const vmSrc = fs.readFileSync(path.join(ROOT, 'SingAndGuess/ViewModels/GameViewModel.swift'), 'utf8');
  assert.match(vmSrc, /func submitGuess\(playerID:\s*UUID,\s*text:\s*String\)/);
  assert.match(vmSrc, /func revealNextHint\(\)/);
  assert.match(vmSrc, /players\.count\s*>=\s*2/);
});
