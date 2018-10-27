// Copyright 2018 The open Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package open

import (
	"context"
	"os/exec"
	"testing"
)

const (
	googleURI = "http://google.com"
)

func TestRun(t *testing.T) {
	testcases := []struct {
		name    string
		input   string
		wantErr bool
	}{
		{
			name:    "Valid",
			input:   googleURI,
			wantErr: false,
		},
		{
			name:    "InvalidURIInput",
			input:   "xxxxxxxxxxxxxxx",
			wantErr: true,
		},
	}

	for _, tc := range testcases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			if err := Run(tc.input); (err != nil) != tc.wantErr {
				if execErr, ok := err.(*exec.ExitError); ok {
					err = execErr
				}
				t.Fatalf("failed to open.Run(%q): %+v", tc.input, err)
			}
		})
	}
}

func TestRunContext(t *testing.T) {
	testcases := []struct {
		name    string
		input   string
		wantErr bool
	}{
		{
			name:    "Valid",
			input:   googleURI,
			wantErr: false,
		},
		{
			name:    "InvalidURIInput",
			input:   "xxxxxxxxxxxxxxx",
			wantErr: true,
		},
	}

	for _, tc := range testcases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			if err := RunContext(context.Background(), tc.input); (err != nil) != tc.wantErr {
				if execErr, ok := err.(*exec.ExitError); ok {
					err = execErr
				}
				t.Fatalf("failed to open.RunContext(%q): %+v", tc.input, err)
			}
		})
	}
}

func TestStart(t *testing.T) {
	testcases := []struct {
		name    string
		input   string
		wantErr bool
	}{
		{
			name:    "Valid",
			input:   googleURI,
			wantErr: false,
		},
		{
			name:    "InvalidURIInput",
			input:   "xxxxxxxxxxxxxxx",
			wantErr: true,
		},
	}

	for _, tc := range testcases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			waitFn, err := Start(tc.input)
			if err != nil {
				t.Errorf("failed to open.Start(%q): %+v", tc.input, err)
			}
			if err := waitFn(); (err != nil) != tc.wantErr {
				if execErr, ok := err.(*exec.ExitError); ok {
					err = execErr
				}
				t.Fatalf("failed to cmd.Wait()): %+v", err)
			}
		})
	}
}

func TestStartContext(t *testing.T) {
	testcases := []struct {
		name    string
		input   string
		wantErr bool
	}{
		{
			name:    "Valid",
			input:   googleURI,
			wantErr: false,
		},
		{
			name:    "InvalidURIInput",
			input:   "xxxxxxxxxxxxxxx",
			wantErr: true,
		},
	}

	for _, tc := range testcases {
		tc := tc
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			waitFn, err := Start(tc.input)
			if err != nil {
				t.Errorf("failed to open.StartContext(%q): %+v", tc.input, err)
			}
			if err := waitFn(); (err != nil) != tc.wantErr {
				if execErr, ok := err.(*exec.ExitError); ok {
					err = execErr
				}
				t.Fatalf("failed to cmd.Wait()): %+v", err)
			}
		})
	}
}
